#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsProgressiveMigration.h"
#import "Lumberjack.h"
#import "NSError+LjsAdditions.h"
#import "NSArray+LjsAdditions.h"
#import "NSDictionary+LjsAdditions.h"
#import <CoreData/CoreData.h>
#import "LjsIdGenerator.h"
#import "LjsDateHelper.h"


#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

/**
 key for the destination model in the dictionary that is returned by the 
 `findPathDestinationAndMappingModelWithModelPaths:` method
 */
static NSString *const kDesintationModelKey = @"com.littlejoysoftware.core data progressive migration model key";

/**
 key for the mapping model in the dictionary that is returned by the 
 `findPathDestinationAndMappingModelWithModelPaths:` method
 */
static NSString *const kMappingModelKey = @"com.littlejoysoftware.core data progressive migration mapping key";

/**
 key for the model path in the dictionary that is returned by the 
 `findPathDestinationAndMappingModelWithModelPaths:` method
 */
static NSString *const kModelPathKey = @"com.littlejoysoftware.core data progressive migration model path key";

static NSString *const kErrorDomain = @"com.littlejoysoftware.core data progressive migration";

typedef enum : NSUInteger {
  kErrorCode = 8001
} error_codes;


/**
 LjsProgressMigration (Private)
 */
@interface LjsProgressiveMigration ()

/** @name Properties */

/**
 a timestamped diretory in which all the migration work is done
 */
@property (nonatomic, copy) NSString *timestampedDirectory;
@property (nonatomic, strong) NSArray *ignorableModels;

/** @name Utilitiy */
- (NSArray *) collectModelVersions; 
- (NSDictionary *) findPathDestinationAndMappingModelWithModelPaths:(NSArray *) aModelPaths
                                                        sourceModel:(NSManagedObjectModel *) aSourceModel;

- (NSURL *) URLforDestinationStoreWithSourceStoreURL:(NSURL *) aSourceStoreURL 
                                           modelName:(NSString *) aModelName
                                      storeExtension:(NSString *) aStoreExtention
                                               error:(NSError **) aError;

- (BOOL) makeBackupsToPreserveSourceWithSourceStoreURL:(NSURL *) aSourceStoreURL
                                   destinationStoreURL:(NSURL *) aDestinationStoreURL
                                             modelName:(NSString *) aModelName
                                        storeExtension:(NSString *) aStoreExtension
                                                 error:(NSError **) aError;

- (NSError *) errorWithMessage:(NSString *) aMessage;


@end

@implementation LjsProgressiveMigration


#pragma mark Memory Management

- (NSError *) errorWithMessage:(NSString *) aMessage {
  return [NSError errorWithDomain:kErrorDomain code:kErrorCode localizedDescription:aMessage];
}

/**
 @return a initialized instance 
 sets the timepstamed directory property to `migration-` _current-date_
 */
- (id) init {
  self = [super init];
  if (self) {
    NSDateFormatter *df = [LjsDateHelper orderedDateFormatterWithMillis];
    NSString *dateStr = [df stringFromDate:[NSDate date]];
    self.timestampedDirectory = [NSString stringWithFormat:@"migration-%@", dateStr];
  }
  return self;
}

- (id) initWithIgnorableModels:(NSArray *) aIgnorableModels {
  self = [self init];
  if (self != nil) {
    self.ignorableModels = [NSArray arrayWithArray:aIgnorableModels];
  }
  return self;
}

/*
 recursively walks over all the model versions and attempts to merge each in turn with the
 store found at soureStoreURL. 
 @return YES if the migration was successful and NO if not
 @param aSourceStoreURL the store that is to be migrated to
 @param aStoreType the kind of store (have seen problems with in memory stores)
 @param aFinalModel the model that we are trying to migrate to
 @param aError if non-NULL will be populated if there is an error - this will
 be indicated by a return value of NO
 */
- (BOOL) progressivelyMigrateURL:(NSURL *) aSourceStoreURL
                       storeType:(NSString *) aStoreType 
                         toModel:(NSManagedObjectModel *) aFinalModel 
                           error:(NSError **) aError {

  NSDictionary *sourceMetadata = 
  [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:aStoreType
                                                             URL:aSourceStoreURL
                                                           error:aError];
  // no metadata - return nil
  if (sourceMetadata == nil) return NO;
  
  // compatible model - nil the error and return YES
  if ([aFinalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
    if (aError != NULL) *aError = nil;
    return YES;
  }
  
  //Find the source model
  NSManagedObjectModel *sourceModel = [NSManagedObjectModel 
                                       mergedModelFromBundles:nil
                                       forStoreMetadata:sourceMetadata];
  if (sourceModel == nil) {
    NSString *msg = [@"failed to create source model from metadata: "
                     stringByAppendingFormat:@"%@", sourceMetadata];
    DDLogError(msg); if (aError != NULL) { *aError = [self errorWithMessage:msg]; }
    return NO;
  }
  
  //Find all of the mom and momd files in the Resources directory
  NSArray *modelPaths = [self collectModelVersions];
  if ([modelPaths has_objects] == NO) {
    NSString *message = @"No models found in bundle.";
    DDLogError(message); if (aError != NULL) { *aError = [self errorWithMessage:message]; }
    return NO;
  }

  //DDLogDebug(@"found these model paths: %@", modelPaths);
  
  //See if we can find a matching path, destination (mom) model, and mapping model
  NSDictionary *map = [self findPathDestinationAndMappingModelWithModelPaths:modelPaths
                                                                 sourceModel:sourceModel];
  if (map == nil) {
    NSString *message = @"Could not find matching destination MOM and mapping.";
    DDLogError(message); if (aError != NULL) { *aError = [self errorWithMessage:message]; }
    return NO;
  }
  

  NSMappingModel *mappingModel = [map objectForKey:kMappingModelKey];
  NSManagedObjectModel *destinationModel = [map objectForKey:kDesintationModelKey];
  NSString *modelPath = [map objectForKey:kModelPathKey];


  //We have a mapping model and a destination model.  Time to migrate
  NSMigrationManager *manager = [[NSMigrationManager alloc] 
                                 initWithSourceModel:sourceModel
                                 destinationModel:destinationModel];

  NSString *modelName = [[modelPath lastPathComponent] stringByDeletingPathExtension];
  NSString *storeExtension = [[aSourceStoreURL path] pathExtension];
  NSURL *destinationStoreURL = [self URLforDestinationStoreWithSourceStoreURL:aSourceStoreURL
                                                                    modelName:modelName
                                                               storeExtension:storeExtension
                                                                        error:aError];
  if (destinationStoreURL == nil) {
    // error populated in the URLforDestinationStore
    return NO;
  }
  
  // do migration - if returns NO, then we return NO
  if ([manager migrateStoreFromURL:aSourceStoreURL 
                              type:aStoreType 
                           options:nil 
                  withMappingModel:mappingModel 
                  toDestinationURL:destinationStoreURL 
                   destinationType:aStoreType 
                destinationOptions:nil 
                             error:aError] == NO) return NO;
  

  //Migration was successful, move the files around to preserve the source
  if ([self makeBackupsToPreserveSourceWithSourceStoreURL:aSourceStoreURL
                                      destinationStoreURL:destinationStoreURL
                                                modelName:modelName
                                           storeExtension:storeExtension
                                                    error:aError] == NO) return NO;
    
  //We may not be at the "current" model yet, so recurse
  return [self progressivelyMigrateURL:aSourceStoreURL
                             storeType:aStoreType 
                               toModel:aFinalModel 
                                 error:aError];
}

/*
 @return an array of file paths to momd and mom model versions found in the
 main bundle
 */
- (NSArray *) collectModelVersions {
  NSBundle *main = [NSBundle mainBundle];
  NSArray *momdArray = [main pathsForResourcesOfType:@"momd" 
                                         inDirectory:nil];
  NSMutableArray *modelPaths = [NSMutableArray array];
  for (NSString *momdPath in momdArray) {
    NSString *resourceSubpath = [momdPath lastPathComponent];
    NSArray *array = [main pathsForResourcesOfType:@"mom" 
                                       inDirectory:resourceSubpath];
    [modelPaths addObjectsFromArray:array];
  }
  NSArray* otherModels = [main pathsForResourcesOfType:@"mom" 
                                           inDirectory:nil];
  [modelPaths addObjectsFromArray:otherModels];
  
  NSArray *ignorable = self.ignorableModels;
  if ([ignorable has_objects] == NO) {
    return [NSArray arrayWithArray:modelPaths];
  }

  NSArray *filtered = [modelPaths filteredArrayUsingPassingBlock:^BOOL(NSString *path, NSUInteger idx, BOOL *stop) {
    NSString *filename = [[path lastPathComponent] stringByDeletingPathExtension];
    return [ignorable containsObject:filename] == NO;
  }];
  
  return filtered;
}

/*
 @return a dictionary that contains an NSMappingModel, an NSManagedObjectModel,
 and path the model that is built by trying to contruct a mapping model from
 the model paths and the source model
 @param aModelPaths a list of model paths
 @param aSourceModel the model we are trying to migration _from_
 */
- (NSDictionary *) findPathDestinationAndMappingModelWithModelPaths:(NSArray *) aModelPaths
                                                        sourceModel:(NSManagedObjectModel *) aSourceModel {
  for (NSString *path in aModelPaths) {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSManagedObjectModel *destMom = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    NSString *sourceVersion = [[[aSourceModel versionIdentifiers] allObjects] first];
    NSString *targetVersion = [[[destMom versionIdentifiers] allObjects] first];
    if ([sourceVersion isEqualToString:targetVersion] == YES) {
      DDLogDebug(@"model versions are the same: '%@'", targetVersion);
      continue;
    }

    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:aSourceModel
                                                          destinationModel:destMom];
    if (mappingModel == nil) {
      DDLogError(@"no mapping model from '%@' to '%@'", sourceVersion, targetVersion);
      return nil;
    }
    
    return @{kMappingModelKey : mappingModel,
             kDesintationModelKey : destMom,
             kModelPathKey : path};
             
  }
  return nil;
}

/*
 @return a file URL to a temporary directory where the migration work will be
 done.  if there is an error, this method returns nil and attempts to populate
 the aError parameter
 @param aSourceStoreURL the original source store url
 @param aModelName the name of the model we are migrating from
 @param aStoreExtention the file extension of the store
 @param aError will be populated if there is an error and the argument is non-NULL
 */
- (NSURL *) URLforDestinationStoreWithSourceStoreURL:(NSURL *) aSourceStoreURL 
                                           modelName:(NSString *) aModelName
                                      storeExtension:(NSString *) aStoreExtention
                                               error:(NSError **) aError {
  NSString *baseDirPath = [[aSourceStoreURL path] stringByDeletingLastPathComponent];
  NSString *timestampDirPath = [baseDirPath stringByAppendingPathComponent:self.timestampedDirectory];
  
  NSString *lastPathDir = [baseDirPath lastPathComponent];
  if ([lastPathDir isEqualToString:self.timestampedDirectory] == NO) {
    if ([[NSFileManager defaultManager] fileExistsAtPath:timestampDirPath] == NO) {
      if ([[NSFileManager defaultManager] createDirectoryAtPath:timestampDirPath
                                    withIntermediateDirectories:YES
                                                     attributes:nil error:aError] == NO) {
        NSString *message = [@"Could not create tmp directory "
                             stringByAppendingFormat:@"%@ at path %@",
                             self.timestampedDirectory, timestampDirPath];
        DDLogError(message);  if (aError != NULL) { *aError = [self errorWithMessage:message]; }
        return nil;
      }
    }
  }
  
  NSString *destStoreName = [NSString stringWithFormat:@"%@.%@", 
                             aModelName, aStoreExtention];
  NSString *storePath = [timestampDirPath stringByAppendingPathComponent:destStoreName];
  
  return [NSURL fileURLWithPath:storePath];
}


/*
 @return YES if the backup process was success and NO otherwise.  if the backup
 fails, the aError will be populated if it is non-NULL
 @param aSourceStoreURL the source store
 @param aDestinationStoreURL the destination store
 @param aModelName the name of the model we are migrating
 @param aStoreExtension the file extension of the store
 @param aError populated when non-NULL and the backup is unsuccessful
 */
- (BOOL) makeBackupsToPreserveSourceWithSourceStoreURL:(NSURL *) aSourceStoreURL
                                   destinationStoreURL:(NSURL *) aDestinationStoreURL
                                             modelName:(NSString *) aModelName
                                        storeExtension:(NSString *) aStoreExtension
                                                 error:(NSError **) aError {
  NSString *storePath = [aDestinationStoreURL path];
  
  NSString *guid = [LjsIdGenerator generateUUID];
  guid = [guid stringByAppendingString:@"-ORIGINAL-"];
  guid = [guid stringByAppendingFormat:@"-%@", aModelName];
  guid = [guid stringByAppendingPathExtension:aStoreExtension];
  NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
  NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];
  
  
  if ([[NSFileManager defaultManager] moveItemAtPath:[aSourceStoreURL path]
                                              toPath:backupPath
                                               error:aError] == NO) {
    //Failed to move the file
    return NO;
  }
  
  //Move the destination to the source path
  if ([[NSFileManager defaultManager] moveItemAtPath:storePath
                                              toPath:[aSourceStoreURL path]
                                               error:aError] == NO) {
    //Try to back out the source move first, no point in checking it for errors
    [[NSFileManager defaultManager] moveItemAtPath:backupPath
                                            toPath:[aSourceStoreURL path]
                                             error:nil];
    return NO;
  }

  return YES;
}


@end
