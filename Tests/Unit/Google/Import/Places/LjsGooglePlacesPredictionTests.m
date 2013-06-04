// Copyright 2012 Little Joy Software. All rights reserved.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsGoogleImportTest_Super.h"
#import "LjsGooglePlacesPrediction.h"
#import "LjsValidator.h"
#import "SBJson.h"
#import "SBJSON+LjsAdditions.h"

@interface LjsGooglePlacesPredictionTests : LjsGoogleImportTest_Super

@end

@implementation LjsGooglePlacesPredictionTests

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void) setUpClass {
  // Run at start of all tests in the class
  [super setUpClass];
}

- (void) tearDownClass {
  // Run at end of all tests in the class
  [super tearDownClass];
}

- (void) setUp {
  self.resourceName = @"google-places-autocomplete-sample";
  [super setUp];  
}

- (void) tearDown {
  // Run after each test method
  [super tearDown];
}  

- (void) test_predictionTestInit {

  NSError *error = nil;
  SBJsonParser *parser = [[SBJsonParser alloc] init];
  NSDictionary *dict = [parser objectWithString:self.jsonResource error:&error];
  
  if (dict == nil) {
    GHTestLog(@"failed because of an error: %@", error);
  }
  
  GHAssertNotNil(dict, @"error: %@", error);
  
  LjsGooglePlacesPrediction *prediction = nil;
  NSArray *predictions = [dict objectForKey:@"predictions"];
  
  for (NSDictionary *predDict in predictions) {
    prediction = [[LjsGooglePlacesPrediction alloc]
                 initWithDictionary:predDict];
    GHAssertNotNil(prediction, nil);
    GHAssertNotNil(prediction.stablePlaceId, nil);
    GHAssertNotNil(prediction.searchReferenceId, nil);
    GHAssertNotNil(prediction.tokens, nil);
    GHAssertNotNil(prediction.types, nil);
    GHAssertNotNil(prediction.matchedRanges, nil);
  }
}

@end
