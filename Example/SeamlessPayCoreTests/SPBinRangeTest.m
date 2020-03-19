//
//  SPBinRangeTest.m
//  SeamlessPayCoreTests
//
//

#import <XCTest/XCTest.h>

#import "../../SeamlessPayCore/Classes/SPBINRange.h"
#import "../../SeamlessPayCore/Classes/SPCardBrand.h"

@interface SPBINRange(Testing)

@property (nonatomic) NSUInteger length;
@property (nonatomic) NSString *qRangeLow;
@property (nonatomic) NSString *qRangeHigh;
@property (nonatomic) SPCardBrand brand;

- (BOOL)matchesNumber:(NSString *)number;

@end

@interface SPBinRangeTest : XCTestCase

@end

@implementation SPBinRangeTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAllRanges {
    for (SPBINRange *binRange in [SPBINRange allRanges]) {
        XCTAssertEqual(binRange.qRangeLow.length, binRange.qRangeHigh.length);
    }
}

- (void)testMatchesNumber {
    SPBINRange *binRange = [SPBINRange new];
    binRange.qRangeLow = @"134";
    binRange.qRangeHigh = @"167";
    
    XCTAssertFalse([binRange matchesNumber:@"0"]);
    XCTAssertTrue([binRange matchesNumber:@"1"]);
    XCTAssertFalse([binRange matchesNumber:@"2"]);

    XCTAssertFalse([binRange matchesNumber:@"00"]);
    XCTAssertTrue([binRange matchesNumber:@"13"]);
    XCTAssertTrue([binRange matchesNumber:@"14"]);
    XCTAssertTrue([binRange matchesNumber:@"16"]);
    XCTAssertFalse([binRange matchesNumber:@"20"]);

    XCTAssertFalse([binRange matchesNumber:@"133"]);
    XCTAssertTrue([binRange matchesNumber:@"134"]);
    XCTAssertTrue([binRange matchesNumber:@"135"]);
    XCTAssertTrue([binRange matchesNumber:@"167"]);
    XCTAssertFalse([binRange matchesNumber:@"168"]);
    
    XCTAssertFalse([binRange matchesNumber:@"1244"]);
    XCTAssertTrue([binRange matchesNumber:@"1340"]);
    XCTAssertTrue([binRange matchesNumber:@"1344"]);
    XCTAssertTrue([binRange matchesNumber:@"1444"]);
    XCTAssertTrue([binRange matchesNumber:@"1670"]);
    XCTAssertTrue([binRange matchesNumber:@"1679"]);
    XCTAssertFalse([binRange matchesNumber:@"1680"]);

    binRange.qRangeLow = @"004";
    binRange.qRangeHigh = @"017";

    XCTAssertTrue([binRange matchesNumber:@"0"]);
    XCTAssertFalse([binRange matchesNumber:@"1"]);

    XCTAssertTrue([binRange matchesNumber:@"00"]);
    XCTAssertTrue([binRange matchesNumber:@"01"]);
    XCTAssertFalse([binRange matchesNumber:@"10"]);
    XCTAssertFalse([binRange matchesNumber:@"20"]);

    XCTAssertFalse([binRange matchesNumber:@"000"]);
    XCTAssertFalse([binRange matchesNumber:@"002"]);
    XCTAssertTrue([binRange matchesNumber:@"004"]);
    XCTAssertTrue([binRange matchesNumber:@"009"]);
    XCTAssertTrue([binRange matchesNumber:@"014"]);
    XCTAssertTrue([binRange matchesNumber:@"017"]);
    XCTAssertFalse([binRange matchesNumber:@"019"]);
    XCTAssertFalse([binRange matchesNumber:@"020"]);
    XCTAssertFalse([binRange matchesNumber:@"100"]);

    XCTAssertFalse([binRange matchesNumber:@"0000"]);
    XCTAssertFalse([binRange matchesNumber:@"0021"]);
    XCTAssertTrue([binRange matchesNumber:@"0044"]);
    XCTAssertTrue([binRange matchesNumber:@"0098"]);
    XCTAssertTrue([binRange matchesNumber:@"0143"]);
    XCTAssertTrue([binRange matchesNumber:@"0173"]);
    XCTAssertFalse([binRange matchesNumber:@"0195"]);
    XCTAssertFalse([binRange matchesNumber:@"0202"]);
    XCTAssertFalse([binRange matchesNumber:@"1004"]);

    binRange.qRangeLow = @"";
    binRange.qRangeHigh = @"";
    XCTAssertTrue([binRange matchesNumber:@""]);
    XCTAssertTrue([binRange matchesNumber:@"1"]);
}

- (void)testBinRangesForNumber {
    NSArray<SPBINRange *> *binRanges;
    
    binRanges = [SPBINRange binRangesForNumber:@"4136000000008"];
    XCTAssertEqual(binRanges.count, 3U);
    
    binRanges = [SPBINRange binRangesForNumber:@"4242424242424242"];
    XCTAssertEqual(binRanges.count, 2U);
    
    binRanges = [SPBINRange binRangesForNumber:@"5555555555554444"];
    XCTAssertEqual(binRanges.count, 2U);
    
    binRanges = [SPBINRange binRangesForNumber:@""];
    XCTAssertEqual(binRanges.count, [SPBINRange allRanges].count);
    
    binRanges = [SPBINRange binRangesForNumber:@"123"];
    XCTAssertEqual(binRanges.count, 1U);
}

- (void)testBinRangesForBrand {
    NSArray *allBrands = @[@(SPCardBrandVisa),
                           @(SPCardBrandAmex),
                           @(SPCardBrandMasterCard),
                           @(SPCardBrandDiscover),
                           @(SPCardBrandJCB),
                           @(SPCardBrandDinersClub),
                           @(SPCardBrandUnionPay),
                           @(SPCardBrandUnknown)];
    for (NSNumber *brand in allBrands) {
        NSArray<SPBINRange *> *binRanges = [SPBINRange binRangesForBrand:brand.integerValue];
        for (SPBINRange *binRange in binRanges) {
            XCTAssertEqual(binRange.brand, brand.integerValue);
        }
    }
}

- (void)testMostSpecificBinRangeForNumber {
    SPBINRange *binRange;
    
    binRange = [SPBINRange mostSpecificBINRangeForNumber:@""];
    XCTAssertNotEqual(binRange.brand, SPCardBrandUnknown);
    
    binRange = [SPBINRange mostSpecificBINRangeForNumber:@"4242424242422"];
    XCTAssertEqual(binRange.brand, SPCardBrandVisa);
    XCTAssertEqual(binRange.length, 16U);
    
    binRange = [SPBINRange mostSpecificBINRangeForNumber:@"4136000000008"];
    XCTAssertEqual(binRange.brand, SPCardBrandVisa);
    XCTAssertEqual(binRange.length, 13U);
    
    binRange = [SPBINRange mostSpecificBINRangeForNumber:@"4242424242424242"];
    XCTAssertEqual(binRange.brand, SPCardBrandVisa);
    XCTAssertEqual(binRange.length, 16U);
}

@end
