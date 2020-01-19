/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "NSCharacterSet+Extras.h"

@implementation NSCharacterSet (Extras)

+ (instancetype)sp_asciiDigitCharacterSet {
    static NSCharacterSet *cs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs = [self characterSetWithCharactersInString:@"0123456789"];
    });
    return cs;
}

+ (instancetype)sp_invertedAsciiDigitCharacterSet {
    static NSCharacterSet *cs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs = [[self sp_asciiDigitCharacterSet] invertedSet];
    });
    return cs;
}

@end

void linkNSCharacterSetCategory(void){}
