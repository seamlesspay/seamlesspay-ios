/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface SPEmailAddressValidator : NSObject

+ (BOOL)stringIsValidPartialEmailAddress:(nullable NSString *)string;
+ (BOOL)stringIsValidEmailAddress:(nullable NSString *)string;

@end
