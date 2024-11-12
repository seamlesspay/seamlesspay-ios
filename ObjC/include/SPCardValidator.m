/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardValidator.h"
#import "SPCardValidator+Extras.h"

#import "NSCharacterSet+Extras.h"
#import "SPBINRange.h"

@implementation SPCardValidator

+ (NSString *)sanitizedNumericStringForString:(NSString *)string {
  return stringByRemovingCharactersFromSet(string, [NSCharacterSet sp_invertedAsciiDigitCharacterSet]);
}

+ (NSString *)stringByRemovingSpacesFromString:(NSString *)string {
  NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
  return stringByRemovingCharactersFromSet(string, set);
}

static NSString *_Nonnull stringByRemovingCharactersFromSet(NSString *_Nonnull string,
                                                            NSCharacterSet *_Nonnull cs) {
  NSRange range = [string rangeOfCharacterFromSet:cs];
  if (range.location != NSNotFound) {
    NSMutableString *newString = [[string
                                   substringWithRange:NSMakeRange(0, range.location)] mutableCopy];
    NSUInteger lastPosition = NSMaxRange(range);
    while (lastPosition < string.length) {
      range = [string
               rangeOfCharacterFromSet:cs
               options:(NSStringCompareOptions)kNilOptions
               range:NSMakeRange(lastPosition,
                                 string.length - lastPosition)];
      if (range.location == NSNotFound) {
        break;
      }
      if (range.location != lastPosition) {
        [newString
         appendString:[string
                       substringWithRange:NSMakeRange(lastPosition,
                                                      range.location -
                                                      lastPosition)]];
      }
      lastPosition = NSMaxRange(range);
    }
    if (lastPosition != string.length) {
      [newString
       appendString:[string
                     substringWithRange:NSMakeRange(lastPosition,
                                                    string.length -
                                                    lastPosition)]];
    }
    return newString;
  } else {
    return string;
  }
}

+ (BOOL)stringIsNumeric:(NSString * __nullable)string {
  // The entire concept of this method needs to be reviewed and possibly changed.
  // Currently, stringIsNumeric considers empty strings as numeric.
  // To maintain consistency with this logic for nil strings, the following quick fix has been added.

  if (string == nil) {
    return YES;
  }

  return [string rangeOfCharacterFromSet:[NSCharacterSet sp_invertedAsciiDigitCharacterSet]]
    .location == NSNotFound;
}

+ (SPCardValidationState)validationStateForExpirationMonth:(NSString *)expirationMonth {

  NSString *sanitizedExpiration = [self stringByRemovingSpacesFromString:expirationMonth];

  if (![self stringIsNumeric:sanitizedExpiration]) {
    return SPCardValidationStateInvalid;
  }

  switch (sanitizedExpiration.length) {
    case 0:
      return SPCardValidationStateIncomplete;
    case 1:
      return ([sanitizedExpiration isEqualToString:@"0"] ||
              [sanitizedExpiration isEqualToString:@"1"])
      ? SPCardValidationStateIncomplete
      : SPCardValidationStateValid;
    case 2:
      return (0 < sanitizedExpiration.integerValue &&
              sanitizedExpiration.integerValue <= 12)
      ? SPCardValidationStateValid
      : SPCardValidationStateInvalid;
    default:
      return SPCardValidationStateInvalid;
  }
}

+ (SPCardValidationState)validationStateForExpirationYear:(NSString *)expirationYear
                                                  inMonth:(NSString *)expirationMonth
                                            inCurrentYear:(NSInteger)currentYear
                                             currentMonth:(NSInteger)currentMonth {

  NSInteger moddedYear = currentYear % 100;

  if (![self stringIsNumeric:expirationMonth] || ![self stringIsNumeric:expirationYear]) {
    return SPCardValidationStateInvalid;
  }

  NSString *sanitizedMonth = [self sanitizedNumericStringForString:expirationMonth];
  NSString *sanitizedYear = [self sanitizedNumericStringForString:expirationYear];

  switch (sanitizedYear.length) {
    case 0:
    case 1:
      return SPCardValidationStateIncomplete;
    case 2: {
      if ([self validationStateForExpirationMonth:sanitizedMonth] == SPCardValidationStateInvalid) {
        return SPCardValidationStateInvalid;
      } else {
        if (sanitizedYear.integerValue == moddedYear) {
          return sanitizedMonth.integerValue >= currentMonth
          ? SPCardValidationStateValid
          : SPCardValidationStateInvalid;
        } else {
          return sanitizedYear.integerValue > moddedYear
          ? SPCardValidationStateValid
          : SPCardValidationStateInvalid;
        }
      }
    }
    default:
      return SPCardValidationStateInvalid;
  }
}

+ (SPCardValidationState)
validationStateForExpirationYear:(NSString *)expirationYear
inMonth:(NSString *)expirationMonth {
  return [self validationStateForExpirationYear:expirationYear
                                        inMonth:expirationMonth
                                  inCurrentYear:[self currentYear]
                                   currentMonth:[self currentMonth]];
}

+ (SPCardValidationState)validationStateForCVC:(NSString *)cvc
                                     cardBrand:(SPCardBrand)brand {

  if (![self stringIsNumeric:cvc]) {
    return SPCardValidationStateInvalid;
  }

  NSString *sanitizedCvc = [self sanitizedNumericStringForString:cvc];

  NSUInteger minLength = [self minCVCLength];
  NSUInteger maxLength = [self maxCVCLengthForCardBrand:brand];
  if (sanitizedCvc.length < minLength) {
    return SPCardValidationStateIncomplete;
  } else if (sanitizedCvc.length > maxLength) {
    return SPCardValidationStateInvalid;
  } else {
    return SPCardValidationStateValid;
  }
}

+ (SPCardValidationState)validationStateForNumber:(NSString *)cardNumber
                              validatingCardBrand:(BOOL)validatingCardBrand {

  NSString *sanitizedNumber =
  [self stringByRemovingSpacesFromString:cardNumber];
  if (sanitizedNumber.length == 0) {
    return SPCardValidationStateIncomplete;
  }
  if (![self stringIsNumeric:sanitizedNumber]) {
    return SPCardValidationStateInvalid;
  }

  SPBINRange *binRange = [SPBINRange mostSpecificBINRangeForNumber:sanitizedNumber];
  if (binRange.brand == SPCardBrandUnknown && validatingCardBrand) {
    return SPCardValidationStateInvalid;
  }

  if (sanitizedNumber.length == binRange.length) {
    BOOL isValidLuhn = [self stringIsValidLuhn:sanitizedNumber];
    return isValidLuhn ? SPCardValidationStateValid : SPCardValidationStateInvalid;
  } else if (sanitizedNumber.length > binRange.length) {
    return SPCardValidationStateInvalid;
  } else {
    return SPCardValidationStateIncomplete;
  }
}

+ (NSUInteger)minCVCLength {
  return 3;
}

+ (NSUInteger)maxCVCLengthForCardBrand:(SPCardBrand)brand {
  switch (brand) {
    case SPCardBrandAmex:
    case SPCardBrandUnknown:
      return 4;
    default:
      return 3;
  }
}

+ (SPCardBrand)brandForNumber:(NSString *)cardNumber {
  NSString *sanitizedNumber = [self sanitizedNumericStringForString:cardNumber];
  NSSet *brands = [self possibleBrandsForNumber:sanitizedNumber];
  if (brands.count == 1) {
    return (SPCardBrand)[brands.anyObject integerValue];
  }
  return SPCardBrandUnknown;
}

+ (NSSet *)possibleBrandsForNumber:(NSString *)cardNumber {
  NSArray<SPBINRange *> *binRanges = [SPBINRange binRangesForNumber:cardNumber];
  NSMutableSet *possibleBrands =
  [NSMutableSet setWithArray:[binRanges valueForKeyPath:@"brand"]];
  [possibleBrands removeObject:@(SPCardBrandUnknown)];
  return [possibleBrands copy];
}

+ (NSSet<NSNumber *> *)lengthsForCardBrand:(SPCardBrand)brand {
  NSMutableSet *set = [NSMutableSet set];
  NSArray<SPBINRange *> *binRanges = [SPBINRange binRangesForBrand:brand];
  for (SPBINRange *binRange in binRanges) {
    [set addObject:@(binRange.length)];
  }
  return [set copy];
}

+ (NSInteger)maxLengthForCardBrand:(SPCardBrand)brand {
  NSInteger maxLength = -1;
  for (NSNumber *length in [self lengthsForCardBrand:brand]) {
    if (length.integerValue > maxLength) {
      maxLength = length.integerValue;
    }
  }
  return maxLength;
}

+ (NSInteger)fragmentLengthForCardBrand:(SPCardBrand)brand {
  return
  [[[self cardNumberFormatForBrand:brand] lastObject] unsignedIntegerValue];
}

+ (BOOL)stringIsValidLuhn:(NSString *)number {
  BOOL odd = true;
  int sum = 0;
  NSMutableArray *digits = [NSMutableArray arrayWithCapacity:number.length];

  for (int i = 0; i < (NSInteger)number.length; i++) {
    [digits addObject:[number substringWithRange:NSMakeRange(i, 1)]];
  }

  for (NSString *digitStr in [digits reverseObjectEnumerator]) {
    int digit = [digitStr intValue];
    if ((odd = !odd))
      digit *= 2;
    if (digit > 9)
      digit -= 9;
    sum += digit;
  }

  return sum % 10 == 0;
}

+ (NSInteger)currentYear {
  NSCalendar *calendar = [[NSCalendar alloc]
                          initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear
                                                 fromDate:[NSDate date]];
  return dateComponents.year % 100;
}

+ (NSInteger)currentMonth {
  NSCalendar *calendar = [[NSCalendar alloc]
                          initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth
                                                 fromDate:[NSDate date]];
  return dateComponents.month;
}

+ (SPCardValidationState)validationStateForPostalCode:(NSString *)postalCode {
  // Check for nil or empty string
  if (postalCode == nil || postalCode.length == 0) {
      return SPCardValidationStateIncomplete;
  }

  // Check length (3-10 characters)
  if (postalCode.length < self.postalCodeMinLength || postalCode.length > self.postalCodeMaxLength) {
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

+ (NSUInteger)postalCodeMinLength {
  return 3;
}

+ (NSUInteger)postalCodeMaxLength {
  return 10;
}

@end
