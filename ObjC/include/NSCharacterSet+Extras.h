/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface NSCharacterSet (Extras)

+ (instancetype)sp_asciiDigitCharacterSet;
+ (instancetype)sp_invertedAsciiDigitCharacterSet;
+ (instancetype)sp_letterCharacterSet;
+ (instancetype)sp_postalCodeCharacterSet;

@end

void linkNSCharacterSetCategory(void);
