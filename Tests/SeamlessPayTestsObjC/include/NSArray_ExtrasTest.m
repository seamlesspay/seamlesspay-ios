//
//  NSArray_ExtrasTest.m
//  SeamlessPayTests
//
//

#import <XCTest/XCTest.h>

#import "NSArray+Extras.h"


@interface NSArray_ExtrasTest : XCTestCase

@end

@implementation NSArray_ExtrasTest

- (void)test_boundSafeObjectAtIndex_emptyArray {
  NSArray *test = @[];
  XCTAssertNil([test sp_boundSafeObjectAtIndex:5]);
}

- (void)test_boundSafeObjectAtIndex_tooHighIndex {
  NSArray *test = @[@1, @2, @3];
  XCTAssertNil([test sp_boundSafeObjectAtIndex:5]);
}

- (void)test_boundSafeObjectAtIndex_withinBoundsIndex {
  NSArray *test = @[@1, @2, @3];
  XCTAssertEqual([test sp_boundSafeObjectAtIndex:1], @2);
}

@end
