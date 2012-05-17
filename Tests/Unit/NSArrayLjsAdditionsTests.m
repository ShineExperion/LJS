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

// a1 is always the RECEIVED value
// a2 is always the EXPECTED value
// GHAssertNoErr(a1, description, ...)
// GHAssertErr(a1, a2, description, ...)
// GHAssertNotNULL(a1, description, ...)
// GHAssertNULL(a1, description, ...)
// GHAssertNotEquals(a1, a2, description, ...)
// GHAssertNotEqualObjects(a1, a2, desc, ...)
// GHAssertOperation(a1, a2, op, description, ...)
// GHAssertGreaterThan(a1, a2, description, ...)
// GHAssertGreaterThanOrEqual(a1, a2, description, ...)
// GHAssertLessThan(a1, a2, description, ...)
// GHAssertLessThanOrEqual(a1, a2, description, ...)
// GHAssertEqualStrings(a1, a2, description, ...)
// GHAssertNotEqualStrings(a1, a2, description, ...)
// GHAssertEqualCStrings(a1, a2, description, ...)
// GHAssertNotEqualCStrings(a1, a2, description, ...)
// GHAssertEqualObjects(a1, a2, description, ...)
// GHAssertEquals(a1, a2, description, ...)
// GHAbsoluteDifference(left,right) (MAX(left,right)-MIN(left,right))
// GHAssertEqualsWithAccuracy(a1, a2, accuracy, description, ...)
// GHFail(description, ...)
// GHAssertNil(a1, description, ...)
// GHAssertNotNil(a1, description, ...)
// GHAssertTrue(expr, description, ...)
// GHAssertTrueNoThrow(expr, description, ...)
// GHAssertFalse(expr, description, ...)
// GHAssertFalseNoThrow(expr, description, ...)
// GHAssertThrows(expr, description, ...)
// GHAssertThrowsSpecific(expr, specificException, description, ...)
// GHAssertThrowsSpecificNamed(expr, specificException, aName, description, ...)
// GHAssertNoThrow(expr, description, ...)
// GHAssertNoThrowSpecific(expr, specificException, description, ...)
// GHAssertNoThrowSpecificNamed(expr, specificException, aName, description, ...)

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsTestCase.h"
#import "NSArray+LjsAdditions.h"

@interface NSArrayLjsAdditionsTests : LjsTestCase {}
@end

@implementation NSArrayLjsAdditionsTests

//- (id) init {
//  self = [super init];
//  if (self) {
//    // Initialization code here.
//  }
//  return self;
//}
//
//- (void) dealloc {
//}

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void) setUpClass {
  // Run at start of all tests in the class
}

- (void) tearDownClass {
  // Run at end of all tests in the class
}

- (void) setUp {
  // Run before each test method
}

- (void) tearDown {
  // Run after each test method
}  

//- (void)testGHLog {
//  GHTestLog(@"GH test logging is working");
//}

- (void) test_nth {
  NSArray *array;
  NSUInteger index;
  id actual;
  id expected;
  
  array = nil;
  index = 0;
  actual = [array nth:index];
  GHAssertNil(actual, nil);
  
  array = [NSArray array];
  index = 0;
  actual = [array nth:index];
  GHAssertNil(actual, nil);
  
  expected = @"foo";
  array = [NSArray arrayWithObject:expected];
  index = 0;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);
  
  expected = @"foo";
  array = [NSArray arrayWithObjects:@"bar", expected, @"ble", nil];
  index = 1;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);

  expected = @"foo";
  array = [NSArray arrayWithObjects:@"bar", @"ble", expected, nil];
  index = 2;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);

  expected = nil;
  array = [NSArray arrayWithObjects:@"bar", @"ble", nil];
  index = 2;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);
  GHAssertNil(actual, nil);
}

- (void) test_rest {
  NSArray *array;
  NSArray *actual, *expected;
  
  expected = nil;
  array = nil;
  actual = [array rest];
  GHAssertNil(actual, nil);
  
  expected = nil;
  array = [NSArray array];
  actual = [array rest];
  GHAssertNil(actual, nil);
  
  expected = nil;
  array = [NSArray arrayWithObject:@"foo"];
  actual = [array rest];
  GHAssertNil(actual, nil);


  array = [NSArray arrayWithObjects:@"first", @"foo", nil];
  actual = [array rest];
  GHAssertEqualStrings([actual first], @"foo", nil);
}

- (void) test_reverse {
  NSArray *array;
  NSArray *actual, *expected;
  NSUInteger actualCount, expectedCount;
  
  array = nil;
  actual = [array reverse];
  GHAssertNil(actual, nil);
  
  array = [NSArray array];
  actual = [array reverse];
  actualCount = [actual count];
  expectedCount = 0;
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  
  array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  expected = [NSArray arrayWithObjects:@"c", @"b", @"a", nil];
  expectedCount = [expected count];
  actual = [array reverse];
  actualCount = [actual count];
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  for (NSUInteger index; index < actualCount; index++) {
    GHAssertEqualStrings([actual nth:index], [expected nth:index], nil);
  }
}

- (void) test_append {
  id object;
  NSArray *array;
  NSArray *actual, *expected;
  NSUInteger actualCount, expectedCount;
  
  object = nil;
  array = nil;
  actual = [array append:object];
  expected = nil;
  GHAssertNil(actual, nil);

  object = nil;
  array = [NSArray array];
  actual = [array append:object];
  actualCount = [actual count];
  expected = [NSArray array];
  expectedCount = [expected count];
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);

  object = @"d";
  array = [NSArray array];
  actual = [array append:object];
  actualCount = [actual count];
  expected = [NSArray arrayWithObject:object];
  expectedCount = [expected count];
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  GHAssertEqualStrings([actual first], [expected first], nil);
  
  object = @"d";
  array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  actual = [array append:object];
  actualCount = [actual count];
  expected = [NSArray arrayWithObjects:@"a", @"b", @"c", object, nil];
  expectedCount = [expected count];
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  for (NSUInteger index; index < actualCount; index++) {
    GHAssertEqualStrings([actual nth:index], [expected nth:index], nil);
  }

  object = [NSArray arrayWithObjects:@"d", @"e", @"f", nil];
  array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  actual = [array append:object];
  actualCount = [actual count];
  expected = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", nil];
  expectedCount = [expected count];
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  for (NSUInteger index; index < actualCount; index++) {
    GHAssertEqualStrings([actual nth:index], [expected nth:index], nil);
  }
}

- (void) test_emptypTrue {
  NSArray *array = [NSArray array];
  GHAssertTrue([array emptyp], @"should be empty:\n%@", array);
  NSMutableArray *marray = [NSMutableArray array];
  GHAssertTrue([marray emptyp], @"should be empty:\n%@", marray);
}

- (void) test_emptypFalse {
  NSArray *array = [NSArray arrayWithObject:@"a"];
  GHAssertFalse([array emptyp], @"should be empty:\n%@", array);
  NSMutableArray *marray = [NSMutableArray arrayWithObject:@"a"];
  GHAssertFalse([marray emptyp], @"should be empty:\n%@", marray);
}

- (void) test_map {
  NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  NSArray *actual = [array map:^(id obj) {
    return [obj uppercaseString];
  }];
  NSSet *expected = [NSSet setWithObjects:@"A", @"B", @"C", nil];
  GHAssertTrue([LjsValidator array:actual containsStrings:expected allowsOthers:NO],
               @"map should have upcased strings in original array\nactual   %@\nexpected     %@\noriginal    %@",
               actual, expected, array);
}



@end
