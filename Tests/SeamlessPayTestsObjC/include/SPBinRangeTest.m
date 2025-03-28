//
//  SPBinRangeTest.m
//  SeamlessPayTests
//
//

#import <XCTest/XCTest.h>

#import "SPBINRange.h"
#import "SPCardBrand.h"

@interface SPBinRangeTest : XCTestCase

@end

@implementation SPBinRangeTest

// MARK: - Helpers

- (void)expectMatchForNumber:(NSString *)number brand:(SPCardBrand)brand length:(NSUInteger)length {
  SPBINRange *range = [SPBINRange definedBINRangeForNumber:number];
  XCTAssertNotNil(range, @"Expected match for number: %@", number);
  XCTAssertEqual(range.brand, brand);
  XCTAssertEqual(range.length, length);
}

// MARK: - Defined BIN Range Tests

- (void)testVisaMatch {
  [self expectMatchForNumber:@"4" brand:SPCardBrandVisa length:16];
}

- (void)testMastercardMatch {
  [self expectMatchForNumber:@"51" brand:SPCardBrandMasterCard length:16];
  [self expectMatchForNumber:@"55" brand:SPCardBrandMasterCard length:16];
  [self expectMatchForNumber:@"2221" brand:SPCardBrandMasterCard length:16];
  [self expectMatchForNumber:@"2720" brand:SPCardBrandMasterCard length:16];
}

- (void)testAmexMatch {
  [self expectMatchForNumber:@"34" brand:SPCardBrandAmex length:15];
  [self expectMatchForNumber:@"37" brand:SPCardBrandAmex length:15];
}

- (void)testDiscoverMatch {
  [self expectMatchForNumber:@"6011" brand:SPCardBrandDiscover length:16];
  [self expectMatchForNumber:@"622126" brand:SPCardBrandDiscover length:16];
  [self expectMatchForNumber:@"622925" brand:SPCardBrandDiscover length:16];
  [self expectMatchForNumber:@"644" brand:SPCardBrandDiscover length:16];
  [self expectMatchForNumber:@"649" brand:SPCardBrandDiscover length:16];
  [self expectMatchForNumber:@"65" brand:SPCardBrandDiscover length:16];
}

- (void)testDinersClubMatch {
  [self expectMatchForNumber:@"300" brand:SPCardBrandDinersClub length:14];
  [self expectMatchForNumber:@"305" brand:SPCardBrandDinersClub length:14];
  [self expectMatchForNumber:@"36" brand:SPCardBrandDinersClub length:14];
  [self expectMatchForNumber:@"38" brand:SPCardBrandDinersClub length:14];
  [self expectMatchForNumber:@"39" brand:SPCardBrandDinersClub length:14];
  [self expectMatchForNumber:@"309" brand:SPCardBrandDinersClub length:16];
}

- (void)testJCBMatch {
  [self expectMatchForNumber:@"3528" brand:SPCardBrandJCB length:16];
  [self expectMatchForNumber:@"3589" brand:SPCardBrandJCB length:16];
}

- (void)testUnionPayMatch {
  [self expectMatchForNumber:@"62" brand:SPCardBrandUnionPay length:16];
}

// MARK: - Potential Match Tests

- (void)testPotentialMatchesForPartialPrefixes {
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"4"]);      // Visa
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"5"]);      // Mastercard
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"22"]);     // Mastercard (2221+)
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"6"]);      // Discover / UnionPay
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"30"]);     // Diners Club
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"35"]);     // JCB
}

- (void)testPotentialMatchesAtLowerEdgeOfRanges {
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"222"]);    // Mastercard
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"622"]);    // Discover
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"300"]);    // Diners Club
}

- (void)testPotentialMatchesAtUpperEdgeOfRanges {
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"272"]);    // Mastercard
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"6229"]);   // Discover
  XCTAssertTrue([SPBINRange isPotentialBINRangesExistForNumber:@"649"]);    // Discover
}

- (void)testNoPotentialMatchForInvalidPrefixes {
  XCTAssertFalse([SPBINRange isPotentialBINRangesExistForNumber:@"0"]);
  XCTAssertFalse([SPBINRange isPotentialBINRangesExistForNumber:@"8"]);
  XCTAssertFalse([SPBINRange isPotentialBINRangesExistForNumber:@"99"]);
  XCTAssertFalse([SPBINRange isPotentialBINRangesExistForNumber:@"123456"]);
}

// MARK: - BIN Ranges for Brand Tests

- (void)testBinRangesForBrand {
  NSArray *allBrands = @[@(SPCardBrandVisa),
                         @(SPCardBrandAmex),
                         @(SPCardBrandMasterCard),
                         @(SPCardBrandDiscover),
                         @(SPCardBrandJCB),
                         @(SPCardBrandDinersClub),
                         @(SPCardBrandUnionPay)];
  for (NSNumber *brand in allBrands) {
    NSArray<SPBINRange *> *binRanges = [SPBINRange binRangesForBrand:brand.integerValue];
    for (SPBINRange *binRange in binRanges) {
      XCTAssertEqual(binRange.brand, brand.integerValue);
    }
  }
}


@end
