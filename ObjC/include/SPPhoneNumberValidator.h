/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPPhoneNumberValidator : NSObject

+ (NSString *)formattedSanitizedPhoneNumberForString:(NSString *)string;
+ (NSString *)formattedSanitizedPhoneNumberForString:(NSString *)string
                                      forCountryCode:(nullable NSString *)countryCode;

@end

NS_ASSUME_NONNULL_END
