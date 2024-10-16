//
//  NSString_ExtrasTest.m
//  SeamlessPayTests
//

#import <XCTest/XCTest.h>
#import "NSString+Extras.h"

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
