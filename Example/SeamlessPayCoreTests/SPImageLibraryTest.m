//
//  SPImageLibraryTest.m
//  SeamlessPayCoreTests
//


#import <XCTest/XCTest.h>

#import "../../SeamlessPayCore/Classes/SPImageLibrary.h"
#import "../../SeamlessPayCore/Classes/SPImageLibrary+Extras.h"

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
  XCTAssertEqual([SPImageLibrary applePayCardImage], [SPImageLibrary safeImageNamed:@"stp_card_applepay" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary amexCardImage], [SPImageLibrary safeImageNamed:@"stp_card_amex" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary dinersClubCardImage], [SPImageLibrary safeImageNamed:@"stp_card_diners" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary discoverCardImage], [SPImageLibrary safeImageNamed:@"stp_card_discover" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary jcbCardImage], [SPImageLibrary safeImageNamed:@"stp_card_jcb" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary masterCardCardImage], [SPImageLibrary safeImageNamed:@"stp_card_mastercard" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary unionPayCardImage], [SPImageLibrary safeImageNamed:@"stp_card_unionpay_en" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary visaCardImage], [SPImageLibrary safeImageNamed:@"stp_card_visa" templateIfAvailable:NO]);
  XCTAssertEqual([SPImageLibrary unknownCardCardImage], [SPImageLibrary safeImageNamed:@"stp_card_unknown" templateIfAvailable:YES]);
}

- (void)testBrandImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary brandImageForCardBrand:brand];

    switch (brand) {
      case SPCardBrandVisa:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_visa" templateIfAvailable:NO]);
        break;
      case SPCardBrandAmex:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_amex" templateIfAvailable:NO]);
        break;
      case SPCardBrandMasterCard:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_mastercard" templateIfAvailable:NO]);
        break;
      case SPCardBrandDiscover:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_discover" templateIfAvailable:NO]);
        break;
      case SPCardBrandJCB:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_jcb" templateIfAvailable:NO]);
        break;
      case SPCardBrandDinersClub:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_diners" templateIfAvailable:NO]);
        break;
      case SPCardBrandUnionPay:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_unionpay_en" templateIfAvailable:NO]);
        break;
      case SPCardBrandUnknown:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_unknown" templateIfAvailable:YES]);
        break;
    }
  }
}

- (void)testTemplatedBrandImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary templatedBrandImageForCardBrand:brand];

    switch (brand) {
      case SPCardBrandVisa:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_visa_template" templateIfAvailable:YES]);
        break;
      case SPCardBrandAmex:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_amex_template" templateIfAvailable:YES]);
        break;
      case SPCardBrandMasterCard:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_mastercard_template" templateIfAvailable:YES]);
        break;
      case SPCardBrandDiscover:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_discover_template" templateIfAvailable:YES]);
        break;
      case SPCardBrandJCB:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_jcb_template" templateIfAvailable:YES]);
        break;
      case SPCardBrandDinersClub:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_diners_template" templateIfAvailable:YES]);
        break;
      case SPCardBrandUnionPay:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_unionpay_template_en" templateIfAvailable:YES]);
        break;
      case SPCardBrandUnknown:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_unknown" templateIfAvailable:YES]);
        break;
    }
  }
}

- (void)testCVCImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary cvcImageForCardBrand:brand];

    switch (brand) {
      case SPCardBrandAmex:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_cvc_amex" templateIfAvailable:NO]);
        break;

      default:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_cvc" templateIfAvailable:NO]);
        break;
    }
  }
}

- (void)testErrorImageForCardBrand {
  for (NSNumber *brandNumber in self.cardBrands) {
    SPCardBrand brand = (SPCardBrand)[brandNumber integerValue];
    UIImage *image = [SPImageLibrary errorImageForCardBrand:brand];

    switch (brand) {
      case SPCardBrandAmex:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_error_amex" templateIfAvailable:NO]);
        break;

      default:
        XCTAssertEqual(image, [SPImageLibrary safeImageNamed:@"stp_card_error" templateIfAvailable:NO]);
        break;
    }
  }
}

@end
