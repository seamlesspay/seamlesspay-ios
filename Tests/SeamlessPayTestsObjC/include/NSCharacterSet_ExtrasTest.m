//
//  NSCharacterSet_ExtrasTest.m
//  SeamlessPayTests
//

#import <XCTest/XCTest.h>
#import "NSCharacterSet+Extras.h"

static NSUInteger countOfCharactersFromSetInString(NSString * _Nonnull string, NSCharacterSet * _Nonnull cs) {
  NSRange range = [string rangeOfCharacterFromSet:cs];
  NSUInteger count = 0;
  if (range.location != NSNotFound) {
    NSUInteger lastPosition = NSMaxRange(range);
    count += range.length;
    while (lastPosition < string.length) {
      range = [string rangeOfCharacterFromSet:cs options:(NSStringCompareOptions)kNilOptions range:NSMakeRange(lastPosition, string.length - lastPosition)];
      if (range.location == NSNotFound) {
        break;
      } else {
        count += range.length;
        lastPosition = NSMaxRange(range);
      }
    }
  }

  return count;
}

@interface NSCharacterSet_ExtrasTest : XCTestCase

@end

@implementation NSCharacterSet_ExtrasTest

- (void)testAsciiDigitCharacterSet {
  NSUInteger numberOfDigits = countOfCharactersFromSetInString(@"12a4", [NSCharacterSet sp_asciiDigitCharacterSet]);
  XCTAssert(numberOfDigits);
  XCTAssertEqual(numberOfDigits, 3);
  numberOfDigits = countOfCharactersFromSetInString(@"1234", [NSCharacterSet sp_asciiDigitCharacterSet]);
  XCTAssertEqual(numberOfDigits, 4);
  numberOfDigits = countOfCharactersFromSetInString(@"abcd", [NSCharacterSet sp_asciiDigitCharacterSet]);
  XCTAssertEqual(numberOfDigits, 0);
}

- (void)testInvertedAsciiDigitCharacterSet{
  XCTAssert([@"1234" rangeOfCharacterFromSet:[NSCharacterSet sp_invertedAsciiDigitCharacterSet]].location == NSNotFound);
  XCTAssertFalse([@"abcd" rangeOfCharacterFromSet:[NSCharacterSet sp_invertedAsciiDigitCharacterSet]].location == NSNotFound);
}


@end
