//
//  SPFPXBankBrandTest.m
//  SeamlessPayTests
//
//

#import <XCTest/XCTest.h>

#import "SPFPXBankBrand.h"

@interface SPFPXBankBrandTest : XCTestCase

@end

@implementation SPFPXBankBrandTest

- (void)testStringFromBrand {
  NSArray<NSNumber *> *brands = @[
    @(SPFPXBankBrandAffinBank),
    @(SPFPXBankBrandAllianceBank),
    @(SPFPXBankBrandAmbank),
    @(SPFPXBankBrandBankIslam),
    @(SPFPXBankBrandBankMuamalat),
    @(SPFPXBankBrandBankRakyat),
    @(SPFPXBankBrandBSN),
    @(SPFPXBankBrandCIMB),
    @(SPFPXBankBrandHongLeongBank),
    @(SPFPXBankBrandHSBC),
    @(SPFPXBankBrandKFH),
    @(SPFPXBankBrandMaybank2E),
    @(SPFPXBankBrandMaybank2U),
    @(SPFPXBankBrandOcbc),
    @(SPFPXBankBrandPublicBank),
    @(SPFPXBankBrandCIMB),
    @(SPFPXBankBrandRHB),
    @(SPFPXBankBrandStandardChartered),
    @(SPFPXBankBrandUOB),
    @(SPFPXBankBrandUnknown),
  ];

  for (NSNumber *brandNumber in brands) {
    SPFPXBankBrand brand = [brandNumber integerValue];
    NSString *brandName = SPStringFromFPXBankBrand(brand);
    NSString *brandID = SPIdentifierFromFPXBankBrand(brand);
    SPFPXBankBrand reverseTransformedBrand = SPFPXBankBrandFromIdentifier(brandID);
    XCTAssertEqual(reverseTransformedBrand, brand);

    switch (brand) {
      case SPFPXBankBrandAffinBank:
        XCTAssertEqualObjects(brandID, @"affin_bank");
        XCTAssertEqualObjects(brandName, @"Affin Bank");
        break;
      case SPFPXBankBrandAllianceBank:
        XCTAssertEqualObjects(brandID, @"alliance_bank");
        XCTAssertEqualObjects(brandName, @"Alliance Bank");
        break;
      case SPFPXBankBrandAmbank:
        XCTAssertEqualObjects(brandID, @"ambank");
        XCTAssertEqualObjects(brandName, @"AmBank");
        break;
      case SPFPXBankBrandBankIslam:
        XCTAssertEqualObjects(brandID, @"bank_islam");
        XCTAssertEqualObjects(brandName, @"Bank Islam");
        break;
      case SPFPXBankBrandBankMuamalat:
        XCTAssertEqualObjects(brandID, @"bank_muamalat");
        XCTAssertEqualObjects(brandName, @"Bank Muamalat");
        break;
      case SPFPXBankBrandBankRakyat:
        XCTAssertEqualObjects(brandID, @"bank_rakyat");
        XCTAssertEqualObjects(brandName, @"Bank Rakyat");
        break;
      case SPFPXBankBrandBSN:
        XCTAssertEqualObjects(brandID, @"bsn");
        XCTAssertEqualObjects(brandName, @"BSN");
        break;
      case SPFPXBankBrandCIMB:
        XCTAssertEqualObjects(brandID, @"cimb");
        XCTAssertEqualObjects(brandName, @"CIMB Clicks");
        break;
      case SPFPXBankBrandHongLeongBank:
        XCTAssertEqualObjects(brandID, @"hong_leong_bank");
        XCTAssertEqualObjects(brandName, @"Hong Leong Bank");
        break;
      case SPFPXBankBrandHSBC:
        XCTAssertEqualObjects(brandID, @"hsbc");
        XCTAssertEqualObjects(brandName, @"HSBC BANK");
        break;
      case SPFPXBankBrandKFH:
        XCTAssertEqualObjects(brandID, @"kfh");
        XCTAssertEqualObjects(brandName, @"KFH");
        break;
      case SPFPXBankBrandMaybank2E:
        XCTAssertEqualObjects(brandID, @"maybank2e");
        XCTAssertEqualObjects(brandName, @"Maybank2E");
        break;
      case SPFPXBankBrandMaybank2U:
        XCTAssertEqualObjects(brandID, @"maybank2u");
        XCTAssertEqualObjects(brandName, @"Maybank2U");
        break;
      case SPFPXBankBrandOcbc:
        XCTAssertEqualObjects(brandID, @"ocbc");
        XCTAssertEqualObjects(brandName, @"OCBC Bank");
        break;
      case SPFPXBankBrandPublicBank:
        XCTAssertEqualObjects(brandID, @"public_bank");
        XCTAssertEqualObjects(brandName, @"Public Bank");
        break;
      case SPFPXBankBrandRHB:
        XCTAssertEqualObjects(brandID, @"rhb");
        XCTAssertEqualObjects(brandName, @"RHB Bank");
        break;
      case SPFPXBankBrandStandardChartered:
        XCTAssertEqualObjects(brandID, @"standard_chartered");
        XCTAssertEqualObjects(brandName, @"Standard Chartered");
        break;
      case SPFPXBankBrandUOB:
        XCTAssertEqualObjects(brandID, @"uob");
        XCTAssertEqualObjects(brandName, @"UOB Bank");
        break;
      case SPFPXBankBrandUnknown:
        XCTAssertEqualObjects(brandID, @"unknown");
        XCTAssertEqualObjects(brandName, @"Unknown");
        break;
    }
  };
}
@end
