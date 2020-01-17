//
//  SPEmailAddressValidator.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

@interface SPEmailAddressValidator : NSObject

+ (BOOL)stringIsValidPartialEmailAddress:(nullable NSString *)string;
+ (BOOL)stringIsValidEmailAddress:(nullable NSString *)string;

@end
