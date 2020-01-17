//
//  SPEmailAddressValidator.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPEmailAddressValidator.h"

@implementation SPEmailAddressValidator

+ (BOOL)stringIsValidPartialEmailAddress:(nullable NSString *)string {
    return [[string mutableCopy] replaceOccurrencesOfString:@"@" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, string.length)] <= 1;
}

+ (BOOL)stringIsValidEmailAddress:(NSString *)string {
    if (!string) {
        return NO;
    }
    // regex from http://www.regular-expressions.info/email.html
    NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:[string lowercaseString]];
}

@end
