#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsGoogleRgReply.h"
#import "Lumberjack.h"
#import "LjsGoogleNmoReverseGeocode.h"
#import "NSArray+LjsAdditions.h"
#import "NSMutableArray+LjsAdditions.h"
#import "NSDate+LjsAdditions.h"
#import "NSDecimalNumber+LjsAdditions.h"


#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation LjsGoogleRgReply


#pragma mark Memory Management



- (NSUInteger) count {
  if (self.dictionary == nil) {
    return 0;
  } else {
    NSArray *results = [self.dictionary objectForKey:@"results"];
    return [results count];
  }
}

- (NSArray *) geocodes {
  NSArray *result;
  if ([self statusHasResults]) {
    NSArray *results = [self.dictionary objectForKey:@"results"];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[results count]];
    for (NSDictionary *dict in results) {
      [array nappend:[[LjsGoogleNmoReverseGeocode alloc]
                      initWithDictionary:dict]];
    }
    result = [NSArray arrayWithArray:array];
  } else if ([self statusNoResults]) {
    result = [NSArray array];
  } else {
    result = nil;
  }
  return result;
}



- (NSString *) description {
  return [NSString stringWithFormat:@"#<Reverse Geo Reply:  %@ %ld>",
          [self status], (long)[self count]];
}


@end
