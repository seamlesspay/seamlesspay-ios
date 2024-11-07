/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "SPCardBrand.h"
#import "SPCardValidationState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class contains static methods to validate card numbers, expiration dates,
 and CVCs.
 */
@interface SPCardValidator : NSObject

/**
 Returns a copy of the passed string with all non-numeric characters removed.
 */
+ (NSString *)sanitizedNumericStringForString:(NSString *)string;

/**
 Whether or not the target string contains only numeric characters.
 */
+ (BOOL)stringIsNumeric:(NSString * __nullable)string;

/**
 Validates a card number, passed as a string. This will return
 SPCardValidationStateInvalid for numbers that are too short or long, contain
 invalid characters, do not pass Luhn validation, or (optionally) do not match
 a number format issued by a major card brand.

 @param cardNumber The card number to validate. Ex. @"4242424242424242"
 @param validatingCardBrand Whether or not to enforce that the number appears to
 be issued by a major card brand (or could be). For example, no issuing card
 network currently issues card numbers beginning with the digit 9; if an
 otherwise correct-length and luhn-valid card number beginning with 9
 (example: 9999999999999995) were passed to this method, it would return
 SPCardValidationStateInvalid if this parameter were YES and
 SPCardValidationStateValid if this parameter were NO. If unsure, you should
 use YES for this value.

 @return SPCardValidationStateValid if the number is valid,
 SPCardValidationStateInvalid if the number is invalid, or
 SPCardValidationStateIncomplete if the number is a substring of a valid
 card (e.g. @"4242").
 */
+ (SPCardValidationState)validationStateForNumber:(nullable NSString *)cardNumber
                              validatingCardBrand:(BOOL)validatingCardBrand;

/**
 The card brand for a card number or substring thereof.

 @param cardNumber A card number, or partial card number. For
 example, @"4242", @"5555555555554444", or @"123".

 @return The brand for that card number. The example parameters would
 return SPCardBrandVisa, SPCardBrandMasterCard, and
 SPCardBrandUnknown, respectively.
 */
+ (SPCardBrand)brandForNumber:(NSString *)cardNumber;

/**
 The possible number lengths for cards associated with a card brand. For
 example, Discover card numbers contain 16 characters, while American Express
 cards contain 15 characters.

 @param brand The brand to return lengths for.

 @return The set of possible lengths cards associated with that brand can be.
 */
+ (NSSet<NSNumber *> *)lengthsForCardBrand:(SPCardBrand)brand;

/**
 The maximum possible length the number of a card associated with the specified
 brand could be.

 For example, Visa cards could be either 13 or 16 characters, so this method
 would return 16 for the that card brand.

 @param brand The brand to return the max length for.

 @return The maximum length card numbers associated with that brand could be.
 */
+ (NSInteger)maxLengthForCardBrand:(SPCardBrand)brand;

/**
 The length of the final grouping of digits to use when formatting a card number
 for display.

 For example, Visa cards display their final 4 numbers, e.g. "4242", while
 American Express cards display their final 5 digits, e.g. "10005".


 @param brand The brand to return the fragment length for.

 @return The final fragment length card numbers associated with that brand use.
 */
+ (NSInteger)fragmentLengthForCardBrand:(SPCardBrand)brand;

/**
 Validates an expiration month, passed as an (optionally 0-padded) string.

 Example valid values are "3", "12", and "08". Example invalid values are "99",
 "a", and "00". Incomplete values include "0" and "1".

 @param expirationMonth A string representing a 2-digit expiration month for a
 payment card.

 @return SPCardValidationStateValid if the month is valid,
 SPCardValidationStateInvalid if the month is invalid, or
 SPCardValidationStateIncomplete if the month is a substring of a valid
 month (e.g. @"0" or @"1").
 */
+ (SPCardValidationState)validationStateForExpirationMonth:(NSString *)expirationMonth;

/**
 Validates an expiration year, passed as a string representing the final
 2 digits of the year.

 This considers the period between the current year until 2099 as valid times.
 An example valid year value would be "16" (assuming the current year, as
 determined by [NSDate date], is 2015).

 Will return SPCardValidationStateInvalid for a month/year combination that
 is earlier than the current date (i.e. @"15" and @"04" in October 2015).
 Example invalid year values are "00", "a", and "13". Any 1-digit year string
 will return SPCardValidationStateIncomplete.

 @param expirationYear A string representing a 2-digit expiration year for a
 payment card.
 @param expirationMonth A string representing a valid 2-digit expiration month
 for a payment card. If the month is invalid
 (see `validationStateForExpirationMonth`), this will
 return SPCardValidationStateInvalid.

 @return SPCardValidationStateValid if the year is valid,
 SPCardValidationStateInvalid if the year is invalid, or
 SPCardValidationStateIncomplete if the year is a substring of a valid
 year (e.g. @"1" or @"2").
 */
+ (SPCardValidationState)validationStateForExpirationYear:(NSString *)expirationYear
                                                  inMonth:(NSString *)expirationMonth;

/**
 The max CVC length for a card brand (for example, American Express CVCs are
 4 digits, while all others are 3).

 @param brand The brand to return the max CVC length for.

 @return The maximum length of CVC numbers for cards associated with that brand.
 */
+ (NSUInteger)maxCVCLengthForCardBrand:(SPCardBrand)brand;

/**
 Validates a card's CVC, passed as a numeric string, for the given card brand.

 @param cvc   the CVC to validate
 @param brand the card brand (can be determined from the card's number
 using `brandForNumber`)

 @return Whether the CVC represents a valid CVC for that card brand. For
 example, would return SPCardValidationStateValid for @"123" and
 SPCardBrandVisa, SPCardValidationStateValid for @"1234" and
 SPCardBrandAmericanExpress, SPCardValidationStateIncomplete for @"12" and
 SPCardBrandVisa, and SPCardValidationStateInvalid for @"12345" and any brand.
 */
+ (SPCardValidationState)validationStateForCVC:(NSString *)cvc
                                     cardBrand:(SPCardBrand)brand;

//TODO: Add documentation
+ (SPCardValidationState)validationStateForPostalCode:(nullable NSString *)postalCode;

@end

NS_ASSUME_NONNULL_END
