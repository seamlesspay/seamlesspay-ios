/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardValidationState.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SPPostalCodeIntendedUsage) {
  SPPostalCodeIntendedUsageBillingAddress,
  SPPostalCodeIntendedUsageShippingAddress,
};

@interface SPPostalCodeValidator : NSObject

+ (BOOL)postalCodeIsRequiredForCountryCode:(nullable NSString *)countryCode;
+ (SPCardValidationState)validationStateForPostalCode:(nullable NSString *)postalCode
                                          countryCode:(nullable NSString *)countryCode;
+ (nullable NSString *)formattedSanitizedPostalCodeFromString:(nullable NSString *)postalCode
                                                  countryCode:(nullable NSString *)countryCode
                                                        usage:(SPPostalCodeIntendedUsage)usage;

@end
