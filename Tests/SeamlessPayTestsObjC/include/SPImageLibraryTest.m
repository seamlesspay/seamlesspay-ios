//
//  SPImageLibraryTest.m
//  SeamlessPayTests
//


#import <XCTest/XCTest.h>

#import "SPImageLibrary.h"

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

- (void)testRenewedBrandImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary renewed_brandImageForCardBrand:brand];
    XCTAssertNotNil(image);
  }
}

- (void)testRenewedCVCImageTemplateForCardBrand {
    UIImage *amexCVCImage = [SPImageLibrary renewed_cvcImageTemplateForCardBrand:SPCardBrandAmex];
    XCTAssertNotNil(amexCVCImage);
    XCTAssertEqual(amexCVCImage.renderingMode, UIImageRenderingModeAlwaysTemplate);


    UIImage *otherCVCImage = [SPImageLibrary renewed_cvcImageTemplateForCardBrand:SPCardBrandVisa];
    XCTAssertNotNil(otherCVCImage);
    XCTAssertEqual(otherCVCImage.renderingMode, UIImageRenderingModeAlwaysTemplate);
}

- (void)testRenewedErrorImage {
    UIImage *errorImage = [SPImageLibrary renewed_errorImage];
    XCTAssertNotNil(errorImage);
}

@end

