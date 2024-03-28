//
//  SPPostalCodeValidatorTest.m
//  SeamlessPayTests
//


#import <XCTest/XCTest.h>

#import "SPPostalCodeValidator.h"

@interface SPPostalCodeValidatorTest : XCTestCase

@end

@implementation SPPostalCodeValidatorTest

- (void)testValidUSPostalCodes {
  NSArray *codes = @[
    @"10002",
    @"10002-1234",
    @"100021234",
    @"21218",
  ];
  for (NSString *code in codes) {
    XCTAssertEqual([SPPostalCodeValidator validationStateForPostalCode:code
                                                           countryCode:@"US"],
                   SPCardValidationStateValid,
                   @"Valid US postal code test failed for code: %@", code);
  }
}

- (void)testInvalidUSPostalCodes {
  NSArray *codes = @[
    @"100A03",
    @"12345-12345",
    @"1234512345",
    @"$$$$$",
    @"foo",
  ];
  for (NSString *code in codes) {
    XCTAssertEqual([SPPostalCodeValidator validationStateForPostalCode:code
                                                           countryCode:@"US"],
                   SPCardValidationStateInvalid,
                   @"Invalid US postal code test failed for code: %@", code);
  }
}

- (void)testIncompleteUSPostalCodes {
  NSArray *codes = @[
    @"",
    @"123",
    @"12345-",
    @"12345-12",
  ];
  for (NSString *code in codes) {
    XCTAssertEqual([SPPostalCodeValidator validationStateForPostalCode:code
                                                           countryCode:@"US"],
                   SPCardValidationStateIncomplete,
                   @"Incomplete US postal code test failed for code: %@", code);
  }
}

- (void)testValidGenericPostalCodes {
  NSArray *codes = @[
    @"ABC10002",
    @"10002-ABCD",
    @"ABCDE",
  ];
  for (NSString *code in codes) {
    XCTAssertEqual([SPPostalCodeValidator validationStateForPostalCode:code
                                                           countryCode:@"UK"],
                   SPCardValidationStateValid,
                   @"Valid generic postal code test failed for code: %@", code);
  }
}

- (void)testIncompleteGenericPostalCodes {
  NSArray *codes = @[
    @"",
  ];
  for (NSString *code in codes) {
    XCTAssertEqual([SPPostalCodeValidator validationStateForPostalCode:code
                                                           countryCode:@"UK"],
                   SPCardValidationStateIncomplete,
                   @"Incomplete generic postal code test failed for code: %@", code);
  }
}

@end
