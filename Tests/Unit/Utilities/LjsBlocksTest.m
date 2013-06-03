// Copyright 2012 Little Joy Software. All rights reserved.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
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

#import "LjsTestCase.h"
#import "LjsBlocks.h"

@interface LjsBlocksTest : LjsTestCase {}
@end

@implementation LjsBlocksTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void) setUpClass {
  [super setUpClass];
  // Run at start of all tests in the class
}

- (void) tearDownClass {
  // Run at end of all tests in the class
  [super tearDownClass];
}

- (void) setUp {
  [super setUp];
  // Run before each test method
}

- (void) tearDown {
  // Run after each test method
  [super tearDown];
}  

- (void) test_initWithNibNamed_bundle {
  id blocks = [[LjsBlocks alloc] init];
  assertThat(blocks, nilValue());
}

- (void) test_dotimes {
  __block NSUInteger counter = 0;
  dotimes(5, ^{
    counter++;
  });
  GHAssertEquals(counter, (NSUInteger)5, @"counter should have been incremented 5 times");
}

- (void) test_mapc_type_range {
  NSRange range = {0, 3};
  NSArray *expected = @[@(0), @(1), @(2), @(3)];
  NSMutableArray *actual = [NSMutableArray arrayWithCapacity:4];
  mapc_type_range(range, ^(NSUInteger idx) {
    [actual nappend:@(idx)];
  });
  GHTestLog(@"expected = %@", expected);
  GHTestLog(@"actual = %@", actual);
  [actual mapc:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
    GHAssertTrue([num compare:[expected nth:idx]] == NSOrderedSame,
                 @"should be able to cons up a list from a range");
  }];
}




@end
