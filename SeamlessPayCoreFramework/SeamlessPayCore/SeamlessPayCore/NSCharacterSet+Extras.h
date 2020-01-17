//
//  NSCharacterSet+Extras.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (Extras)

+ (instancetype)sp_asciiDigitCharacterSet;
+ (instancetype)sp_invertedAsciiDigitCharacterSet;


@end

void linkNSCharacterSetCategory(void);
