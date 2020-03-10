//
//  SPCardValidatorTest.m
//  SeamlessPayCoreTests
//

#import <XCTest/XCTest.h>

@import SeamlessPayCore;

@interface SPCardValidator (Testing)

+ (SPCardValidationState)validationStateForExpirationYear:(NSString *)expirationYear
                                                   inMonth:(NSString *)expirationMonth
                                             inCurrentYear:(NSInteger)currentYear
                                              currentMonth:(NSInteger)currentMonth;

+ (SPCardValidationState)validationStateForCard:(SPCardParams *)card
                                   inCurrentYear:(NSInteger)currentYear
                                    currentMonth:(NSInteger)currentMonth;

@end



@interface SPCardValidatorTest : XCTestCase

@end

@implementation SPCardValidatorTest

+ (NSArray *)cardData {
    return @[
             @[@(SPCardBrandVisa), @"4242424242424242", @(SPCardValidationStateValid)],
             @[@(SPCardBrandVisa), @"4242424242422", @(SPCardValidationStateIncomplete)],
             @[@(SPCardBrandVisa), @"4012888888881881", @(SPCardValidationStateValid)],
             @[@(SPCardBrandVisa), @"4000056655665556", @(SPCardValidationStateValid)],
             @[@(SPCardBrandMasterCard), @"5555555555554444", @(SPCardValidationStateValid)],
             @[@(SPCardBrandMasterCard), @"5200828282828210", @(SPCardValidationStateValid)],
             @[@(SPCardBrandMasterCard), @"5105105105105100", @(SPCardValidationStateValid)],
             @[@(SPCardBrandMasterCard), @"2223000010089800", @(SPCardValidationStateValid)],
             @[@(SPCardBrandAmex), @"378282246310005", @(SPCardValidationStateValid)],
             @[@(SPCardBrandAmex), @"371449635398431", @(SPCardValidationStateValid)],
             @[@(SPCardBrandDiscover), @"6011111111111117", @(SPCardValidationStateValid)],
             @[@(SPCardBrandDiscover), @"6011000990139424", @(SPCardValidationStateValid)],
             @[@(SPCardBrandDinersClub), @"36227206271667", @(SPCardValidationStateValid)],
             @[@(SPCardBrandJCB), @"3530111333300000", @(SPCardValidationStateValid)],
             @[@(SPCardBrandJCB), @"3566002020360505", @(SPCardValidationStateValid)],
             @[@(SPCardBrandUnknown), @"1234567812345678", @(SPCardValidationStateInvalid)],
             ];
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNumberSanitization {
    NSArray *tests = @[
                       @[@"4242424242424242", @"4242424242424242"],
                       @[@"XXXXXX", @""],
                       @[@"424242424242424X", @"424242424242424"],
                       @[@"X4242", @"4242"],
                       @[@"4242 4242 4242 4242", @"4242424242424242"]
                       ];
    for (NSArray *test in tests) {
        XCTAssertEqualObjects([SPCardValidator sanitizedNumericStringForString:test[0]], test[1]);
    }
}

- (void)testNumberValidation {
    NSMutableArray *tests = [@[] mutableCopy];
    
    for (NSArray *card in [self.class cardData]) {
        [tests addObject:@[card[2], card[1]]];
    }
    
    [tests addObject:@[@(SPCardValidationStateValid), @"4242 4242 4242 4242"]];
    [tests addObject:@[@(SPCardValidationStateValid), @"4136000000008"]];

    NSArray *badCardNumbers = @[
                                @"0000000000000000",
                                @"9999999999999995",
                                @"1",
                                @"1234123412341234",
                                @"xxx",
                                @"9999999999999999999999",
                                @"42424242424242424242",
                                @"4242-4242-4242-4242",
                                ];
    
    for (NSString *card in badCardNumbers) {
        [tests addObject:@[@(SPCardValidationStateInvalid), card]];
    }
    
    NSArray *possibleCardNumbers = @[
                                     @"4242",
                                     @"5",
                                     @"3",
                                     @"",
                                     @"    ",
                                     @"6011",
                                     @"4012888888881"
                                     ];

    for (NSString *card in possibleCardNumbers) {
        [tests addObject:@[@(SPCardValidationStateIncomplete), card]];
    }
    
    for (NSArray *test in tests) {
        NSString *card = test[1];
        NSNumber *validationState = @([SPCardValidator validationStateForNumber:card validatingCardBrand:YES]);
        NSNumber *expected = test[0];
        if (![validationState isEqual:expected]) {
            XCTFail(@"Expected %@, got %@ for number %@", expected, validationState, card);
        }
    }
    
    XCTAssertEqual(SPCardValidationStateIncomplete, [SPCardValidator validationStateForNumber:@"1" validatingCardBrand:NO]);
    XCTAssertEqual(SPCardValidationStateValid, [SPCardValidator validationStateForNumber:@"0000000000000000" validatingCardBrand:NO]);
    XCTAssertEqual(SPCardValidationStateValid, [SPCardValidator validationStateForNumber:@"9999999999999995" validatingCardBrand:NO]);
    XCTAssertEqual(SPCardValidationStateIncomplete, [SPCardValidator validationStateForNumber:@"4242424242424" validatingCardBrand:YES]);
    XCTAssertEqual(SPCardValidationStateIncomplete, [SPCardValidator validationStateForNumber:nil validatingCardBrand:YES]);
}

- (void)testBrand {
    for (NSArray *test in [self.class cardData]) {
        XCTAssertEqualObjects(@([SPCardValidator brandForNumber:test[1]]), test[0]);
    }
}

- (void)testLengthsForCardBrand {
    NSArray *tests = @[
                       @[@(SPCardBrandVisa), @[@13, @16]],
                       @[@(SPCardBrandMasterCard), @[@16]],
                       @[@(SPCardBrandAmex), @[@15]],
                       @[@(SPCardBrandDiscover), @[@16]],
                       @[@(SPCardBrandDinersClub), @[@14]],
                       @[@(SPCardBrandJCB), @[@16]],
                       @[@(SPCardBrandUnionPay), @[@16]],
                       @[@(SPCardBrandUnknown), @[@16]],
                       ];
    for (NSArray *test in tests) {
        NSSet *lengths = [SPCardValidator lengthsForCardBrand:[test[0] integerValue]];
        NSSet *expected = [NSSet setWithArray:test[1]];
        if (![lengths isEqualToSet:expected]) {
            XCTFail(@"Invalid lengths for brand %@: expected %@, got %@", test[0], expected, lengths);
        }
    }
}

- (void)testFragmentLength {
    NSArray *tests = @[
                       @[@(SPCardBrandVisa), @4],
                       @[@(SPCardBrandMasterCard), @4],
                       @[@(SPCardBrandAmex), @5],
                       @[@(SPCardBrandDiscover), @4],
                       @[@(SPCardBrandDinersClub), @4],
                       @[@(SPCardBrandJCB), @4],
                       @[@(SPCardBrandUnionPay), @4],
                       @[@(SPCardBrandUnknown), @4],
                       ];
    for (NSArray *test in tests) {
        XCTAssertEqualObjects(@([SPCardValidator fragmentLengthForCardBrand:[test[0] integerValue]]), test[1]);
    }
}

- (void)testMonthValidation {
    NSArray *tests = @[
                       @[@"", @(SPCardValidationStateIncomplete)],
                       @[@"0", @(SPCardValidationStateIncomplete)],
                       @[@"1", @(SPCardValidationStateIncomplete)],
                       @[@"2", @(SPCardValidationStateValid)],
                       @[@"9", @(SPCardValidationStateValid)],
                       @[@"10", @(SPCardValidationStateValid)],
                       @[@"12", @(SPCardValidationStateValid)],
                       @[@"13", @(SPCardValidationStateInvalid)],
                       @[@"11a", @(SPCardValidationStateInvalid)],
                       @[@"x", @(SPCardValidationStateInvalid)],
                       @[@"100", @(SPCardValidationStateInvalid)],
                       @[@"00", @(SPCardValidationStateInvalid)],
                       @[@"13", @(SPCardValidationStateInvalid)],
                       ];
    for (NSArray *test in tests) {
        XCTAssertEqualObjects(@([SPCardValidator validationStateForExpirationMonth:test[0]]), test[1]);
    }
}

- (void)testYearValidation {
    NSArray *tests = @[
                       @[@"12", @"15", @(SPCardValidationStateValid)],
                       @[@"8", @"15", @(SPCardValidationStateValid)],
                       @[@"9", @"15", @(SPCardValidationStateValid)],
                       @[@"11", @"16", @(SPCardValidationStateValid)],
                       @[@"11", @"99", @(SPCardValidationStateValid)],
                       @[@"01", @"99", @(SPCardValidationStateValid)],
                       @[@"1", @"99", @(SPCardValidationStateValid)],
                       @[@"00", @"99", @(SPCardValidationStateInvalid)],
                       @[@"12", @"14", @(SPCardValidationStateInvalid)],
                       @[@"7", @"15", @(SPCardValidationStateInvalid)],
                       @[@"12", @"00", @(SPCardValidationStateInvalid)],
                       @[@"13", @"16", @(SPCardValidationStateInvalid)],
                       @[@"12", @"2", @(SPCardValidationStateIncomplete)],
                       @[@"12", @"1", @(SPCardValidationStateIncomplete)],
                       @[@"12", @"0", @(SPCardValidationStateIncomplete)],
                       ];
    
    for (NSArray *test in tests) {
        SPCardValidationState state = [SPCardValidator validationStateForExpirationYear:test[1] inMonth:test[0] inCurrentYear:15 currentMonth:8];
        XCTAssertEqualObjects(@(state), test[2]);
    }
}

- (void)testCVCLength {
    NSArray *tests = @[
                       @[@(SPCardBrandVisa), @3],
                       @[@(SPCardBrandMasterCard), @3],
                       @[@(SPCardBrandAmex), @4],
                       @[@(SPCardBrandDiscover), @3],
                       @[@(SPCardBrandDinersClub), @3],
                       @[@(SPCardBrandJCB), @3],
                       @[@(SPCardBrandUnionPay), @3],
                       @[@(SPCardBrandUnknown), @4],
                       ];
    for (NSArray *test in tests) {
        XCTAssertEqualObjects(@([SPCardValidator maxCVCLengthForCardBrand:[test[0] integerValue]]), test[1]);
    }
}

- (void)testCardValidation {
    NSArray *tests = @[
                       @[@"4242424242424242", @(12), @(15), @"123", @(SPCardValidationStateValid)],
                       @[@"4242424242424242", @(12), @(15), @"x", @(SPCardValidationStateInvalid)],
                       @[@"4242424242424242", @(12), @(15), @"1", @(SPCardValidationStateIncomplete)],
                       @[@"4242424242424242", @(12), @(14), @"123", @(SPCardValidationStateInvalid)],
                       @[@"4242424242424242", @(21), @(15), @"123", @(SPCardValidationStateInvalid)],
                       @[@"42424242", @(12), @(15), @"123", @(SPCardValidationStateIncomplete)],
                       @[@"378282246310005", @(12), @(15), @"1234", @(SPCardValidationStateValid)],
                       @[@"378282246310005", @(12), @(15), @"123", @(SPCardValidationStateValid)],
                       @[@"378282246310005", @(12), @(15), @"12345", @(SPCardValidationStateInvalid)],
                       @[@"1234567812345678", @(12), @(15), @"12345", @(SPCardValidationStateInvalid)],
                       ];
    for (NSArray *test in tests) {
        SPCardParams *card = [[SPCardParams alloc] init];
        card.number = test[0];
        card.expMonth = [test[1] integerValue];
        card.expYear = [test[2] integerValue];
        card.cvc = test[3];
        SPCardValidationState state = [SPCardValidator validationStateForCard:card
                                        inCurrentYear:15 currentMonth:8];
        if (![@(state) isEqualToNumber:test[4]]) {
            XCTFail(@"Wrong validation state for %@. Expected %@, got %@", card.number, test[4], @(state));
        }
    }
}

@end
