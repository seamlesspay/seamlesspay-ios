/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPPaymentCardTextFieldViewModel.h"
#import "NSString+Extras.h"
#import "SPCardValidator+Extras.h"
#import "SPPostalCodeValidator.h"

@implementation SPPaymentCardTextFieldViewModel

- (void)setCardNumber:(NSString *)cardNumber {
  NSString *sanitizedNumber =
      [SPCardValidator sanitizedNumericStringForString:cardNumber];
  SPCardBrand brand = [SPCardValidator brandForNumber:sanitizedNumber];
  NSInteger maxLength = [SPCardValidator maxLengthForCardBrand:brand];
  _cardNumber = [sanitizedNumber sp_safeSubstringToIndex:maxLength];
}

- (NSString *)compressedCardNumber {
  NSString *cardNumber = self.cardNumber;
  if (cardNumber.length == 0) {
    cardNumber = self.defaultPlaceholder;
  }

  SPCardBrand currentBrand = [SPCardValidator brandForNumber:cardNumber];
  if ([self validationStateForField:SPCardFieldTypeNumber] ==
      SPCardValidationStateValid) {
    // Use fragment length
    NSUInteger length =
        [SPCardValidator fragmentLengthForCardBrand:currentBrand];
    NSUInteger index = cardNumber.length - length;

    if (index < cardNumber.length) {
      return [cardNumber sp_safeSubstringFromIndex:index];
    }
  } else {
    // use the card number format
    NSArray<NSNumber *> *cardNumberFormat =
        [SPCardValidator cardNumberFormatForBrand:currentBrand];

    NSUInteger index = 0;
    for (NSNumber *segment in cardNumberFormat) {
      NSUInteger segmentLength = [segment unsignedIntegerValue];
      if (index + segmentLength >= cardNumber.length) {
        return [cardNumber sp_safeSubstringFromIndex:index];
      }
      index += segmentLength;
    }
  }

  return nil;
}

// This might contain slashes.
- (void)setRawExpiration:(NSString *)expiration {
  NSString *sanitizedExpiration =
      [SPCardValidator sanitizedNumericStringForString:expiration];
  self.expirationMonth = [sanitizedExpiration sp_safeSubstringToIndex:2];
  self.expirationYear = [[sanitizedExpiration sp_safeSubstringFromIndex:2]
      sp_safeSubstringToIndex:2];
}

- (NSString *)rawExpiration {
  NSMutableArray *array = [@[] mutableCopy];
  if (self.expirationMonth && ![self.expirationMonth isEqualToString:@""]) {
    [array addObject:self.expirationMonth];
  }

  if ([SPCardValidator
          validationStateForExpirationMonth:self.expirationMonth] ==
      SPCardValidationStateValid) {
    [array addObject:self.expirationYear];
  }
  return [array componentsJoinedByString:@"/"];
}

- (void)setExpirationMonth:(NSString *)expirationMonth {
  NSString *sanitizedExpiration =
      [SPCardValidator sanitizedNumericStringForString:expirationMonth];
  if (sanitizedExpiration.length == 1 &&
      ![sanitizedExpiration isEqualToString:@"0"] &&
      ![sanitizedExpiration isEqualToString:@"1"]) {
    sanitizedExpiration = [@"0" stringByAppendingString:sanitizedExpiration];
  }
  _expirationMonth = [sanitizedExpiration sp_safeSubstringToIndex:2];
}

- (void)setExpirationYear:(NSString *)expirationYear {
  _expirationYear =
      [[SPCardValidator sanitizedNumericStringForString:expirationYear]
          sp_safeSubstringToIndex:2];
}

- (void)setCvc:(NSString *)cvc {
  NSInteger maxLength = [SPCardValidator maxCVCLengthForCardBrand:self.brand];
  _cvc = [[SPCardValidator sanitizedNumericStringForString:cvc]
      sp_safeSubstringToIndex:maxLength];
}

- (void)setPostalCode:(NSString *)postalCode {
  _postalCode = [SPPostalCodeValidator
      formattedSanitizedPostalCodeFromString:postalCode
                                 countryCode:self.postalCodeCountryCode
                                       usage:
                                           SPPostalCodeIntendedUsageBillingAddress];
}

- (void)setPostalCodeCountryCode:(NSString *)postalCodeCountryCode {
  _postalCodeCountryCode = postalCodeCountryCode;
  _postalCode = [SPPostalCodeValidator
      formattedSanitizedPostalCodeFromString:self.postalCode
                                 countryCode:postalCodeCountryCode
                                       usage:
                                           SPPostalCodeIntendedUsageBillingAddress];
}

- (SPCardBrand)brand {
  return [SPCardValidator brandForNumber:self.cardNumber];
}

- (SPCardValidationState)validationStateForField:(SPCardFieldType)fieldType {
  switch (fieldType) {
  case SPCardFieldTypeNumber:
    return [SPCardValidator validationStateForNumber:self.cardNumber
                                 validatingCardBrand:YES];
    break;
  case SPCardFieldTypeExpiration: {
    SPCardValidationState monthState = [SPCardValidator
        validationStateForExpirationMonth:self.expirationMonth];
    SPCardValidationState yearState =
        [SPCardValidator validationStateForExpirationYear:self.expirationYear
                                                  inMonth:self.expirationMonth];
    if (monthState == SPCardValidationStateValid &&
        yearState == SPCardValidationStateValid) {
      return SPCardValidationStateValid;
    } else if (monthState == SPCardValidationStateInvalid ||
               yearState == SPCardValidationStateInvalid) {
      return SPCardValidationStateInvalid;
    } else {
      return SPCardValidationStateIncomplete;
    }
    break;
  }
  case SPCardFieldTypeCVC:
    return [SPCardValidator validationStateForCVC:self.cvc
                                        cardBrand:self.brand];
  case SPCardFieldTypePostalCode:
    return [SPPostalCodeValidator
        validationStateForPostalCode:self.postalCode
                         countryCode:self.postalCodeCountryCode];
  }
}

- (BOOL)isValid {
  return ([self validationStateForField:SPCardFieldTypeNumber] ==
              SPCardValidationStateValid &&
          [self validationStateForField:SPCardFieldTypeExpiration] ==
              SPCardValidationStateValid &&
          [self validationStateForField:SPCardFieldTypeCVC] ==
              SPCardValidationStateValid &&
          (!self.postalCodeRequired ||
           [self validationStateForField:SPCardFieldTypePostalCode] ==
               SPCardValidationStateValid));
}

- (NSString *)defaultPlaceholder {
  return @"---- ---- ---- ----";
  //return @"4242424242424242";
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValid {
  return [NSSet setWithArray:@[
    NSStringFromSelector(@selector(cardNumber)),
    NSStringFromSelector(@selector(expirationMonth)),
    NSStringFromSelector(@selector(expirationYear)),
    NSStringFromSelector(@selector(cvc)),
    NSStringFromSelector(@selector(brand)),
    NSStringFromSelector(@selector(postalCode)),
    NSStringFromSelector(@selector(postalCodeRequired)),
    NSStringFromSelector(@selector(postalCodeCountryCode)),
  ]];
}

@end
