/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPPostalCodeValidator.h"
#import "NSCharacterSet+Extras.h"
#import "NSString+Extras.h"
#import "SPCardValidator.h"
#import "SPPhoneNumberValidator.h"

static NSString *const SPCountryCodeUnitedStates = @"US";

@implementation SPPostalCodeValidator

+ (SPCardValidationState)validationStateForPostalCode:(NSString *)postalCode
                                          countryCode:(NSString *)countryCode {
  NSString *sanitizedCountryCode = countryCode.uppercaseString;
  if ([self postalCodeIsRequiredForCountryCode:countryCode]) {
    if ([sanitizedCountryCode isEqualToString:SPCountryCodeUnitedStates]) {
      return [self validationStateForUSPostalCode:postalCode];
    } else {
      if (postalCode.length > 0) {
        return SPCardValidationStateValid;
      } else {
        return SPCardValidationStateIncomplete;
      }
    }
  } else {
    return SPCardValidationStateValid;
  }
}

+ (SPCardValidationState)validationStateForPostalCode:(NSString *)postalCode {
  // Check for nil or empty string
  if (postalCode == nil || postalCode.length == 0) {
      return SPCardValidationStateIncomplete;
  }

  // Check length (3-10 characters)
  if (postalCode.length < 3 || postalCode.length > 10) {
      return SPCardValidationStateInvalid;
  }

  // Check if string contains only allowed characters
  NSCharacterSet *invalidChars = [[NSCharacterSet sp_postalCodeCharacterSet] invertedSet];
  NSRange range = [postalCode rangeOfCharacterFromSet:invalidChars];

  if (range.location != NSNotFound) {
      return SPCardValidationStateInvalid;
  }

  return SPCardValidationStateValid;
}

static NSUInteger
countOfCharactersFromSetInString(NSString *_Nonnull string,
                                 NSCharacterSet *_Nonnull cs) {
  NSRange range = [string rangeOfCharacterFromSet:cs];
  NSUInteger count = 0;
  if (range.location != NSNotFound) {
    NSUInteger lastPosition = NSMaxRange(range);
    count += range.length;
    while (lastPosition < string.length) {
      range = [string
               rangeOfCharacterFromSet:cs
               options:(NSStringCompareOptions)kNilOptions
               range:NSMakeRange(lastPosition,
                                 string.length - lastPosition)];
      if (range.location == NSNotFound) {
        break;
      } else {
        count += range.length;
        lastPosition = NSMaxRange(range);
      }
    }
  }

  return count;
}

+ (SPCardValidationState)validationStateForUSPostalCode:(NSString *)postalCode {
  NSString *firstFive = [postalCode sp_safeSubstringToIndex:5];
  NSUInteger firstFiveLength = firstFive.length;
  NSUInteger totalLength = postalCode.length;

  BOOL firstFiveIsNumeric = [SPCardValidator stringIsNumeric:firstFive];
  if (!firstFiveIsNumeric) {
    // Non-numbers included in first five characters
    return SPCardValidationStateInvalid;
  } else if (firstFiveLength < 5) {
    // Incomplete ZIP with only numbers
    return SPCardValidationStateIncomplete;
  } else if (totalLength == 5) {
    // Valid 5 digit zip
    return SPCardValidationStateValid;
  } else {
    // ZIP+4 territory
    NSUInteger numberOfDigits = countOfCharactersFromSetInString(postalCode,
                                                                 [NSCharacterSet sp_asciiDigitCharacterSet]);

    if (numberOfDigits > 9) {
      // Too many digits
      return SPCardValidationStateInvalid;
    } else if (numberOfDigits == totalLength) {
      // All numeric postal code entered
      if (numberOfDigits == 9) {
        return SPCardValidationStateValid;
      } else {
        return SPCardValidationStateIncomplete;
      }

    } else if ((numberOfDigits + 1) == totalLength) {
      // Possibly has a separator character for ZIP+4, check to see if
      // its in the right place

      NSString *separatorCharacter =
      [postalCode substringWithRange:NSMakeRange(5, 1)];
      if (countOfCharactersFromSetInString(separatorCharacter,
                                           [NSCharacterSet sp_asciiDigitCharacterSet]) == 0) {
        // Non-digit is in right position to be separator
        if (numberOfDigits == 9) {
          return SPCardValidationStateValid;
        } else {
          return SPCardValidationStateIncomplete;
        }
      } else {
        // Non-digit is in wrong position to be separator
        return SPCardValidationStateInvalid;
      }
    } else {
      // Not a valid zip code (too many non-numeric characters)
      return SPCardValidationStateInvalid;
    }
  }
}
+ (NSString *)formattedSanitizedPostalCodeFromString:(NSString *)postalCode
                                         countryCode:(NSString *)countryCode
                                               usage:(SPPostalCodeIntendedUsage)usage {
  if (countryCode == nil) {
    return postalCode;
  }

  NSString *sanitizedCountryCode = countryCode.uppercaseString;
  if ([sanitizedCountryCode isEqualToString:SPCountryCodeUnitedStates]) {
    return [self formattedSanitizedUSZipCodeFromString:postalCode usage:usage];
  } else {
    return postalCode;
  }
}

+ (NSString *)formattedSanitizedUSZipCodeFromString:(NSString *)zipCode
                                              usage:(SPPostalCodeIntendedUsage)usage {
  NSUInteger maxLength = 0;
  switch (usage) {
    case SPPostalCodeIntendedUsageBillingAddress:
      maxLength = 5;
      break;
    case SPPostalCodeIntendedUsageShippingAddress:
      maxLength = 9;
  }

  NSString *formattedString =
  [[SPCardValidator sanitizedNumericStringForString:zipCode] sp_safeSubstringToIndex:maxLength];

  /*
   If the string is >5 numbers or == 5 and the last char of the unformatted
   string was already a hyphen, insert a hyphen at position 6 for ZIP+4
   */
  if (formattedString.length > 5 ||
      (formattedString.length == 5 &&
       [[zipCode substringFromIndex:(zipCode.length - 1)]
        isEqualToString:@"-"])) {
    NSMutableString *mutableZip = formattedString.mutableCopy;
    [mutableZip insertString:@"-" atIndex:5];
    formattedString = mutableZip.copy;
  }

  return formattedString;
}

+ (BOOL)postalCodeIsRequiredForCountryCode:(NSString *)countryCode {
  if (countryCode == nil) {
    return YES;
  } else {
    return (![[self countriesWithNoPostalCodes]
              containsObject:countryCode.uppercaseString]);
  }
}

+ (NSArray *)countriesWithNoPostalCodes {
  return @[
    @"AE", @"AG", @"AN", @"AO", @"AW", @"BF", @"BI", @"BJ", @"BO", @"BS",
    @"BW", @"BZ", @"CD", @"CF", @"CG", @"CI", @"CK", @"CM", @"DJ", @"DM",
    @"ER", @"FJ", @"GD", @"GH", @"GM", @"GN", @"GQ", @"GY", @"HK", @"IE",
    @"JM", @"KE", @"KI", @"KM", @"KN", @"KP", @"LC", @"ML", @"MO", @"MR",
    @"MS", @"MU", @"MW", @"NR", @"NU", @"PA", @"QA", @"RW", @"SB", @"SC",
    @"SL", @"SO", @"SR", @"ST", @"SY", @"TF", @"TK", @"TL", @"TO", @"TT",
    @"TV", @"TZ", @"UG", @"VU", @"YE", @"ZA", @"ZW"
  ];
}

@end
