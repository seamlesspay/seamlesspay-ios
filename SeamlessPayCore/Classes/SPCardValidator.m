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
  return stringByRemovingCharactersFromSet(
      string, [NSCharacterSet sp_invertedAsciiDigitCharacterSet]);
}

+ (NSString *)stringByRemovingSpacesFromString:(NSString *)string {
  NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
  return stringByRemovingCharactersFromSet(string, set);
}

static NSString *_Nonnull stringByRemovingCharactersFromSet(
    NSString *_Nonnull string, NSCharacterSet *_Nonnull cs) {
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

+ (BOOL)stringIsNumeric:(NSString *)string {
  return [string rangeOfCharacterFromSet:[NSCharacterSet
                                             sp_invertedAsciiDigitCharacterSet]]
             .location == NSNotFound;
}

+ (SPCardValidationState)validationStateForExpirationMonth:
    (NSString *)expirationMonth {

  NSString *sanitizedExpiration =
      [self stringByRemovingSpacesFromString:expirationMonth];

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

+ (SPCardValidationState)
    validationStateForExpirationYear:(NSString *)expirationYear
                             inMonth:(NSString *)expirationMonth
                       inCurrentYear:(NSInteger)currentYear
                        currentMonth:(NSInteger)currentMonth {

  NSInteger moddedYear = currentYear % 100;

  if (![self stringIsNumeric:expirationMonth] ||
      ![self stringIsNumeric:expirationYear]) {
    return SPCardValidationStateInvalid;
  }

  NSString *sanitizedMonth =
      [self sanitizedNumericStringForString:expirationMonth];
  NSString *sanitizedYear =
      [self sanitizedNumericStringForString:expirationYear];

  switch (sanitizedYear.length) {
  case 0:
  case 1:
    return SPCardValidationStateIncomplete;
  case 2: {
    if ([self validationStateForExpirationMonth:sanitizedMonth] ==
        SPCardValidationStateInvalid) {
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
  SPBINRange *binRange =
      [SPBINRange mostSpecificBINRangeForNumber:sanitizedNumber];
  if (binRange.brand == SPCardBrandUnknown && validatingCardBrand) {
    return SPCardValidationStateInvalid;
  }
  if (sanitizedNumber.length == binRange.length) {
    BOOL isValidLuhn = [self stringIsValidLuhn:sanitizedNumber];
    return isValidLuhn ? SPCardValidationStateValid
                       : SPCardValidationStateInvalid;
  } else if (sanitizedNumber.length > binRange.length) {
    return SPCardValidationStateInvalid;
  } else {
    return SPCardValidationStateIncomplete;
  }
}

+ (SPCardValidationState)validationStateForCard:(nonnull SPCardParams *)card
                                  inCurrentYear:(NSInteger)currentYear
                                   currentMonth:(NSInteger)currentMonth {
  SPCardValidationState numberValidation =
      [self validationStateForNumber:card.number validatingCardBrand:YES];
  NSString *expMonthString =
      [NSString stringWithFormat:@"%02lu", (unsigned long)card.expMonth];
  SPCardValidationState expMonthValidation =
      [self validationStateForExpirationMonth:expMonthString];
  NSString *expYearString =
      [NSString stringWithFormat:@"%02lu", (unsigned long)card.expYear % 100];
  SPCardValidationState expYearValidation =
      [self validationStateForExpirationYear:expYearString
                                     inMonth:expMonthString
                               inCurrentYear:currentYear
                                currentMonth:currentMonth];
  SPCardBrand brand = [self brandForNumber:card.number];
  SPCardValidationState cvcValidation = [self validationStateForCVC:card.cvc
                                                          cardBrand:brand];

  NSArray<NSNumber *> *states = @[
    @(numberValidation), @(expMonthValidation), @(expYearValidation),
    @(cvcValidation)
  ];
  BOOL incomplete = NO;
  for (NSNumber *boxedState in states) {
    SPCardValidationState state = [boxedState integerValue];
    if (state == SPCardValidationStateInvalid) {
      return state;
    } else if (state == SPCardValidationStateIncomplete) {
      incomplete = YES;
    }
  }
  return incomplete ? SPCardValidationStateIncomplete
                    : SPCardValidationStateValid;
}

+ (SPCardValidationState)validationStateForCard:(SPCardParams *)card {
  return [self validationStateForCard:card
                        inCurrentYear:[self currentYear]
                         currentMonth:[self currentMonth]];
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

@end
