//
//  SPPhoneNumberValidator.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

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
