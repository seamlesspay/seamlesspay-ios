//
//  SPCardTest.m
//  SeamlessPayCoreTests
//


#import <XCTest/XCTest.h>

#import "../../SeamlessPayCore/Classes/SPCardBrand.h"
#import "../../SeamlessPayCore/Classes/SPCard.h"

@interface SPCard ()

@property (nonatomic, assign, readwrite) SPCardBrand brand;

- (void)setLast4:(NSString *)last4;
- (void)setAllResponseFields:(NSDictionary *)allResponseFields;

@end

@interface SPCardTest : XCTestCase

@end

@implementation SPCardTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBrandFromString {
    XCTAssertEqual([SPCard brandFromString:@"visa"], SPCardBrandVisa);
    XCTAssertEqual([SPCard brandFromString:@"VISA"], SPCardBrandVisa);

    XCTAssertEqual([SPCard brandFromString:@"american express"], SPCardBrandAmex);
    XCTAssertEqual([SPCard brandFromString:@"AMERICAN EXPRESS"], SPCardBrandAmex);

    XCTAssertEqual([SPCard brandFromString:@"mastercard"], SPCardBrandMasterCard);
    XCTAssertEqual([SPCard brandFromString:@"MASTERCARD"], SPCardBrandMasterCard);

    XCTAssertEqual([SPCard brandFromString:@"discover"], SPCardBrandDiscover);
    XCTAssertEqual([SPCard brandFromString:@"DISCOVER"], SPCardBrandDiscover);

    XCTAssertEqual([SPCard brandFromString:@"jcb"], SPCardBrandJCB);
    XCTAssertEqual([SPCard brandFromString:@"JCB"], SPCardBrandJCB);

    XCTAssertEqual([SPCard brandFromString:@"diners club"], SPCardBrandDinersClub);
    XCTAssertEqual([SPCard brandFromString:@"DINERS CLUB"], SPCardBrandDinersClub);

    XCTAssertEqual([SPCard brandFromString:@"unionpay"], SPCardBrandUnionPay);
    XCTAssertEqual([SPCard brandFromString:@"UNIONPAY"], SPCardBrandUnionPay);

    XCTAssertEqual([SPCard brandFromString:@"unknown"], SPCardBrandUnknown);
    XCTAssertEqual([SPCard brandFromString:@"UNKNOWN"], SPCardBrandUnknown);
    
    XCTAssertEqual([SPCard brandFromString:@"garbage"], SPCardBrandUnknown);
    XCTAssertEqual([SPCard brandFromString:@"GARBAGE"], SPCardBrandUnknown);
}

- (void)testFundingFromString {
    XCTAssertEqual([SPCard fundingFromString:@"credit"], SPCardFundingTypeCredit);
    XCTAssertEqual([SPCard fundingFromString:@"CREDIT"], SPCardFundingTypeCredit);

    XCTAssertEqual([SPCard fundingFromString:@"debit"], SPCardFundingTypeDebit);
    XCTAssertEqual([SPCard fundingFromString:@"DEBIT"], SPCardFundingTypeDebit);

    XCTAssertEqual([SPCard fundingFromString:@"prepaid"], SPCardFundingTypePrepaid);
    XCTAssertEqual([SPCard fundingFromString:@"PREPAID"], SPCardFundingTypePrepaid);

    XCTAssertEqual([SPCard fundingFromString:@"other"], SPCardFundingTypeOther);
    XCTAssertEqual([SPCard fundingFromString:@"OTHER"], SPCardFundingTypeOther);

    XCTAssertEqual([SPCard fundingFromString:@"unknown"], SPCardFundingTypeOther);
    XCTAssertEqual([SPCard fundingFromString:@"UNKNOWN"], SPCardFundingTypeOther);

    XCTAssertEqual([SPCard fundingFromString:@"garbage"], SPCardFundingTypeOther);
    XCTAssertEqual([SPCard fundingFromString:@"GARBAGE"], SPCardFundingTypeOther);
}

- (void)testStringFromFunding {
    NSArray<NSNumber *> *values = @[
                                    @(SPCardFundingTypeCredit),
                                    @(SPCardFundingTypeDebit),
                                    @(SPCardFundingTypePrepaid),
                                    @(SPCardFundingTypeOther),
                                    ];

    for (NSNumber *fundingNumber in values) {
        SPCardFundingType funding = (SPCardFundingType)[fundingNumber integerValue];
        NSString *string = [SPCard stringFromFunding:funding];

        switch (funding) {
            case SPCardFundingTypeCredit:
                XCTAssertEqualObjects(string, @"credit");
                break;
            case SPCardFundingTypeDebit:
                XCTAssertEqualObjects(string, @"debit");
                break;
            case SPCardFundingTypePrepaid:
                XCTAssertEqualObjects(string, @"prepaid");
                break;
            case SPCardFundingTypeOther:
                XCTAssertNil(string);
                break;
        }
    }
}




@end
