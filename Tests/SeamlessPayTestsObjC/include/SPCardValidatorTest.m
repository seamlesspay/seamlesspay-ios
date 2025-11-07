//
//  SPCardValidatorTest.m
//  SeamlessPayTests
//

#import <XCTest/XCTest.h>
#import "SPCardValidator.h"

@interface SPCardValidator (Testing)

+ (SPCardValidationState)validationStateForExpirationYear:(NSString *)expirationYear
                                                  inMonth:(NSString *)expirationMonth
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

- (void)testValidCardNumbers {
  for (NSArray *card in [self.class cardData]) {
    NSString *cardNumber = card[1];
    SPCardValidationState expectedState = [card[2] integerValue];
    XCTAssertEqual([SPCardValidator validationStateForNumber:cardNumber],
                   expectedState,
                   @"Expected %@ for card %@", @(expectedState), cardNumber);
  }
}

- (void)testInvalidCardNumbers {
  NSArray *invalidCardNumbers = @[
    @"0000000000000000",
    @"9999999999999995",
    @"1",
    @"1234123412341234",
    @"xxx",
    @"9999999999999999999999",
    @"42424242424242424242",
    @"4242-4242-4242-4242"
  ];
  
  for (NSString *card in invalidCardNumbers) {
    XCTAssertEqual([SPCardValidator validationStateForNumber:card],
                   SPCardValidationStateInvalid,
                   @"Expected invalid state for card %@", card);
  }
}

- (void)testIncompleteCardNumbers {
  NSArray *incompleteCardNumbers = @[
    @"4242",
    @"5",
    @"3",
    @"",
    @"    ",
    @"6011",
    @"4012888888881"
  ];
  
  for (NSString *card in incompleteCardNumbers) {
    XCTAssertEqual([SPCardValidator validationStateForNumber:card],
                   SPCardValidationStateIncomplete,
                   @"Expected incomplete state for card %@", card);
  }
}

- (void)testEdgeCases {
  XCTAssertEqual([SPCardValidator validationStateForNumber:@"1"],
                 SPCardValidationStateInvalid);
  XCTAssertEqual([SPCardValidator validationStateForNumber:@"0000000000000000"],
                 SPCardValidationStateInvalid);
  XCTAssertEqual([SPCardValidator validationStateForNumber:@"9999999999999995"],
                 SPCardValidationStateInvalid);
  XCTAssertEqual([SPCardValidator validationStateForNumber:@"4242424242424"],
                 SPCardValidationStateIncomplete);
  XCTAssertEqual([SPCardValidator validationStateForNumber:nil],
                 SPCardValidationStateIncomplete);
}


- (void)testBrand {
  for (NSArray *test in [self.class cardData]) {
    XCTAssertEqualObjects(@([SPCardValidator brandForNumber:test[1]]), test[0]);
  }
}

- (void)testLengthsForCardBrand {
  NSArray *tests = @[
    @[@(SPCardBrandVisa), @[@16]],
    @[@(SPCardBrandMasterCard), @[@16]],
    @[@(SPCardBrandAmex), @[@15]],
    @[@(SPCardBrandDiscover), @[@16]],
    @[@(SPCardBrandDinersClub), @[@14, @16]],
    @[@(SPCardBrandJCB), @[@16]],
    @[@(SPCardBrandUnionPay), @[@16]],
  ];
  
  for (NSArray *test in tests) {
    NSSet *lengths = [SPCardValidator lengthsForCardBrand:[test[0] integerValue]];
    NSSet *expected = [NSSet setWithArray:test[1]];
    if (![lengths isEqualToSet:expected]) {
      XCTFail(@"Invalid lengths for brand %@: expected %@, got %@", test[0], expected, lengths);
    }
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
    @[@(SPCardBrandAmex), @4],
    @[@(SPCardBrandVisa), @3],
    @[@(SPCardBrandMasterCard), @3],
    @[@(SPCardBrandDiscover), @3],
    @[@(SPCardBrandDinersClub), @3],
    @[@(SPCardBrandJCB), @3],
    @[@(SPCardBrandUnionPay), @3],
    @[@(SPCardBrandUnknown), @3],
  ];
  
  for (NSArray *test in tests) {
    SPCardBrand brand = [test[0] integerValue];
    NSNumber *expectedLength = test[1];
    NSNumber *actualLength = @([SPCardValidator maxCVCLengthForCardBrand:brand]);
    
    XCTAssertEqualObjects(actualLength, expectedLength,
                          @"Unexpected CVC length for card brand %ld: expected %@, got %@",
                          (long)brand, expectedLength, actualLength);
  }
}

- (void)testValidationStateForPostalCode {
  // Test nil postal code
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:nil],
                 SPCardValidationStateIncomplete,
                 @"Nil postal code should return Incomplete");
  
  // Test empty postal code
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@""],
                 SPCardValidationStateIncomplete,
                 @"Empty postal code should return Incomplete");
  
  // Test postal code shorter than minimum length
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"12"],
                 SPCardValidationStateIncomplete,
                 @"Postal code shorter than minimum length should return Incomplete");
  
  // Test postal code longer than maximum length
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"12345678901"],
                 SPCardValidationStateInvalid,
                 @"Postal code longer than maximum length should return Invalid");
  
  // Test valid postal code at minimum length
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"123"],
                 SPCardValidationStateValid,
                 @"Postal code with minimum valid length should return Valid");
  
  // Test valid postal code at maximum length
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"1234567890"],
                 SPCardValidationStateValid,
                 @"Postal code with maximum valid length should return Valid");
  
  // Test valid postal code within range
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"12345"],
                 SPCardValidationStateValid,
                 @"Postal code within valid range should return Valid");
  
  // Test postal code with invalid characters
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"123@#%"],
                 SPCardValidationStateInvalid,
                 @"Postal code with special characters should return Invalid");
  
  // Test postal code with spaces
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"123 45"],
                 SPCardValidationStateValid,
                 @"Postal code with spaces should return Valid");
  
  // Test postal code with numbers and letters
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"1234a"],
                 SPCardValidationStateValid,
                 @"Postal code with letters should return Valid");
  // Test postal code with dashes
  XCTAssertEqual([SPCardValidator validationStateForPostalCode:@"12345-6789"],
                 SPCardValidationStateInvalid,
                 @"Postal code with dashes should return Invalid");
}

@end


