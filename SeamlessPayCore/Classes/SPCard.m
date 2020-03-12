/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCard.h"
#import "SPCard+Extras.h"

#import "NSDictionary+Extras.h"
#import "SPImageLibrary+Extras.h"
#import "SPImageLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCard ()

@property(nonatomic, copy) NSString *cardID;
@property(nonatomic, copy, nullable, readwrite) NSString *name;
@property(nonatomic, copy, readwrite) NSString *last4;
@property(nonatomic, copy, nullable, readwrite) NSString *dynamicLast4;
@property(nonatomic, assign, readwrite) SPCardBrand brand;
@property(nonatomic, assign, readwrite) SPCardFundingType funding;
@property(nonatomic, copy, nullable, readwrite) NSString *country;
@property(nonatomic, copy, nullable, readwrite) NSString *currency;
@property(nonatomic, assign, readwrite) NSUInteger expMonth;
@property(nonatomic, assign, readwrite) NSUInteger expYear;
@property(nonatomic, strong, readwrite) SPAddress *address;
@property(nonatomic, copy, nullable, readwrite) NSDictionary<NSString *, NSString *> *metadata;
@property(nonatomic, copy, readwrite) NSDictionary *allResponseFields;

@end

@implementation SPCard

#pragma mark - SPCardBrand

+ (SPCardBrand)brandFromString:(NSString *)string {

  NSString *brand = [string lowercaseString];
  if ([brand isEqualToString:@"visa"]) {
    return SPCardBrandVisa;
  } else if ([brand isEqualToString:@"american express"]) {
    return SPCardBrandAmex;
  } else if ([brand isEqualToString:@"mastercard"]) {
    return SPCardBrandMasterCard;
  } else if ([brand isEqualToString:@"discover"]) {
    return SPCardBrandDiscover;
  } else if ([brand isEqualToString:@"jcb"]) {
    return SPCardBrandJCB;
  } else if ([brand isEqualToString:@"diners club"]) {
    return SPCardBrandDinersClub;
  } else if ([brand isEqualToString:@"unionpay"]) {
    return SPCardBrandUnionPay;
  } else {
    return SPCardBrandUnknown;
  }
}

+ (NSString *)stringFromBrand:(SPCardBrand)brand {
  return SPStringFromCardBrand(brand);
}

#pragma mark - SPCardFundingType

+ (NSDictionary<NSString *, NSNumber *> *)stringToFundingMapping {
  return @{
    @"credit" : @(SPCardFundingTypeCredit),
    @"debit" : @(SPCardFundingTypeDebit),
    @"prepaid" : @(SPCardFundingTypePrepaid),
  };
}

+ (SPCardFundingType)fundingFromString:(NSString *)string {
  NSString *key = [string lowercaseString];
  NSNumber *fundingNumber = [self stringToFundingMapping][key];

  if (fundingNumber != nil) {
    return (SPCardFundingType)[fundingNumber integerValue];
  }

  return SPCardFundingTypeOther;
}

+ (nullable NSString *)stringFromFunding:(SPCardFundingType)funding {
  return
      [[[self stringToFundingMapping] allKeysForObject:@(funding)] firstObject];
}

#pragma mark -

- (BOOL)isApplePayCard {
  return [self.allResponseFields[@"tokenization_method"]
      isEqualToString:@"apple_pay"];
}

#pragma mark - Equality

- (BOOL)isEqual:(nullable id)other {
  return [self isEqualToCard:other];
}

- (NSUInteger)hash {
  return [self.cardID hash];
}

- (BOOL)isEqualToCard:(nullable SPCard *)other {
  if (self == other) {
    return YES;
  }

  if (!other || ![other isKindOfClass:self.class]) {
    return NO;
  }

  return [self.cardID isEqualToString:other.cardID];
}

#pragma mark - Description

- (NSString *)description {
  NSArray *props = @[
    // Object
    [NSString
        stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],

    // Identifier
    [NSString stringWithFormat:@"cardID = %@", self.cardID],

    // Basic card details
    [NSString stringWithFormat:@"brand = %@",
                               [self.class stringFromBrand:self.brand]],
    [NSString stringWithFormat:@"last4 = %@", self.last4],
    [NSString stringWithFormat:@"expMonth = %lu", (unsigned long)self.expMonth],
    [NSString stringWithFormat:@"expYear = %lu", (unsigned long)self.expYear],
    [NSString stringWithFormat:@"funding = %@",
                               ([self.class stringFromFunding:self.funding])
                                   ?: @"unknown"],

    // Additional card details (alphabetical)
    [NSString stringWithFormat:@"country = %@", self.country],
    [NSString stringWithFormat:@"currency = %@", self.currency],
    [NSString stringWithFormat:@"dynamicLast4 = %@", self.dynamicLast4],
    [NSString stringWithFormat:@"isApplePayCard = %@",
                               (self.isApplePayCard) ? @"YES" : @"NO"],
    [NSString stringWithFormat:@"metadata = %@",
                               (self.metadata) ? @"<redacted>" : nil],

    // Cardholder details
    [NSString stringWithFormat:@"name = %@", (self.name) ? @"<redacted>" : nil],
    [NSString
        stringWithFormat:@"address = %@", (self.address) ? @"<redacted>" : nil],
  ];

  return [NSString
      stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}

- (NSString *)cardObject {
  return @"card";
}

#pragma mark - PaymentOption

- (UIImage *)image {
  return [SPImageLibrary brandImageForCardBrand:self.brand];
}

- (UIImage *)templateImage {
  return [SPImageLibrary templatedBrandImageForCardBrand:self.brand];
}

- (NSString *)label {
  NSString *brand = [self.class stringFromBrand:self.brand];
  return [NSString stringWithFormat:@"%@ %@", brand, self.last4];
}

- (NSString *)cardId {
  return self.cardID;
}

- (BOOL)isReusable {
  return YES;
}

@end

NS_ASSUME_NONNULL_END
