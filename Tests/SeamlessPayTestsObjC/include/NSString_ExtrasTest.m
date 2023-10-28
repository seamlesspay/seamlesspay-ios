//
//  NSString_ExtrasTest.m
//  SeamlessPayCoreTests
//

#import <XCTest/XCTest.h>
#import "../../SeamlessPayObjC/include/NSString+Extras.h"

@interface NSString_ExtrasTest : XCTestCase

@end

@implementation NSString_ExtrasTest

- (void)testSafeSubstringToIndex {
  XCTAssertEqualObjects([@"foo" sp_safeSubstringToIndex:0], @"");
  XCTAssertEqualObjects([@"foo" sp_safeSubstringToIndex:500], @"foo");
  XCTAssertEqualObjects([@"foo" sp_safeSubstringToIndex:1], @"f");
  XCTAssertEqualObjects([@"" sp_safeSubstringToIndex:0], @"");
  XCTAssertEqualObjects([@"" sp_safeSubstringToIndex:1], @"");
}

- (void)testSafeSubstringFromIndex {
  XCTAssertEqualObjects([@"foo" sp_safeSubstringFromIndex:0], @"foo");
  XCTAssertEqualObjects([@"foo" sp_safeSubstringFromIndex:1], @"oo");
  XCTAssertEqualObjects([@"foo" sp_safeSubstringFromIndex:3], @"");
  XCTAssertEqualObjects([@"" sp_safeSubstringFromIndex:0], @"");
  XCTAssertEqualObjects([@"" sp_safeSubstringFromIndex:1], @"");
}

- (void)testReversedString {
  XCTAssertEqualObjects([@"foo" sp_reversedString], @"oof");
  XCTAssertEqualObjects([@"12345" sp_reversedString], @"54321");
  XCTAssertEqualObjects([@"" sp_reversedString], @"");
}

- (void)testStringByRemovingSuffix {
  XCTAssertEqualObjects([@"foobar" sp_stringByRemovingSuffix:@"bar"], @"foo");
  XCTAssertEqualObjects([@"foobar" sp_stringByRemovingSuffix:@"baz"], @"foobar");
  XCTAssertEqualObjects([@"foobar" sp_stringByRemovingSuffix:nil], @"foobar");
  XCTAssertEqualObjects([@"foobar" sp_stringByRemovingSuffix:@"foobar"], @"");
  XCTAssertEqualObjects([@"foobar" sp_stringByRemovingSuffix:@""], @"foobar");
  XCTAssertEqualObjects([@"foobar" sp_stringByRemovingSuffix:@"oba"], @"foobar");

  XCTAssertEqualObjects([@"foobar☺¿" sp_stringByRemovingSuffix:@"bar☺¿"], @"foo");
  XCTAssertEqualObjects([@"foobar☺¿" sp_stringByRemovingSuffix:@"bar¿"], @"foobar☺¿");

  XCTAssertEqualObjects([@"foobar\u202C" sp_stringByRemovingSuffix:@"bar"], @"foobar\u202C");
  XCTAssertEqualObjects([@"foobar\u202C" sp_stringByRemovingSuffix:@"bar\u202C"], @"foo");

  // e + \u0041 => é
  XCTAssertEqualObjects([@"foobare\u0301" sp_stringByRemovingSuffix:@"bare"], @"foobare\u0301");
  XCTAssertEqualObjects([@"foobare\u0301" sp_stringByRemovingSuffix:@"bare\u0301"], @"foo");
  XCTAssertEqualObjects([@"foobare" sp_stringByRemovingSuffix:@"bare\u0301"], @"foobare");

}

@end
