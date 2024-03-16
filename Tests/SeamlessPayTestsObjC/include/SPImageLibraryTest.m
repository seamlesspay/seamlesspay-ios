//
//  SPImageLibraryTest.m
//  SeamlessPayTests
//


#import <XCTest/XCTest.h>

#import "../../SeamlessPayObjC/include/SPImageLibrary.h"
#import "../../SeamlessPayObjC/include/SPImageLibrary+Extras.h"

@interface SPImageLibraryTest : XCTestCase
@property NSArray<NSNumber *> *cardBrands;
@end

@implementation SPImageLibraryTest

- (void)setUp {

  self.cardBrands = @[
    @(SPCardBrandAmex),
    @(SPCardBrandDinersClub),
    @(SPCardBrandDiscover),
    @(SPCardBrandJCB),
    @(SPCardBrandMasterCard),
    @(SPCardBrandUnionPay),
    @(SPCardBrandUnknown),
    @(SPCardBrandVisa),
  ];
}

- (void)testCardIconMethods {
  XCTAssertNotNil([SPImageLibrary applePayCardImage]);
  XCTAssertNotNil([SPImageLibrary amexCardImage]);
  XCTAssertNotNil([SPImageLibrary dinersClubCardImage]);
  XCTAssertNotNil([SPImageLibrary discoverCardImage]);
  XCTAssertNotNil([SPImageLibrary jcbCardImage]);
  XCTAssertNotNil([SPImageLibrary masterCardCardImage]);
  XCTAssertNotNil([SPImageLibrary unionPayCardImage]);
  XCTAssertNotNil([SPImageLibrary visaCardImage]);
  XCTAssertNotNil([SPImageLibrary unknownCardCardImage]);
}

- (void)testBrandImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary brandImageForCardBrand:brand];
    XCTAssertNotNil(image);
  }
}

- (void)testTemplatedBrandImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary templatedBrandImageForCardBrand:brand];
    XCTAssertNotNil(image);
  }
}

- (void)testCVCImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary cvcImageForCardBrand:brand];
    XCTAssertNotNil(image);
  }
}

- (void)testErrorImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary errorImageForCardBrand:brand];
    XCTAssertNotNil(image);
  }
}

@end
