/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPPhoneNumberValidator : NSObject

+ (BOOL)stringIsValidPartialPhoneNumber:(NSString *)string;
+ (BOOL)stringIsValidPhoneNumber:(nullable NSString *)string;
+ (BOOL)stringIsValidPartialPhoneNumber:(NSString *)string
                         forCountryCode:(nullable NSString *)countryCode;
+ (BOOL)stringIsValidPhoneNumber:(NSString *)string
                  forCountryCode:(nullable NSString *)countryCode;
+ (NSString *)formattedSanitizedPhoneNumberForString:(NSString *)string;
+ (NSString *)formattedSanitizedPhoneNumberForString:(NSString *)string
                                      forCountryCode:(nullable NSString *)countryCode;
+ (NSString *)formattedRedactedPhoneNumberForString:(NSString *)string;
+ (NSString *)formattedRedactedPhoneNumberForString:(NSString *)string
                                     forCountryCode:(nullable NSString *)countryCode;

@end

NS_ASSUME_NONNULL_END
