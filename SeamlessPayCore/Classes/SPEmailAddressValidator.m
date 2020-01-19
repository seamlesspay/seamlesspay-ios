/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPEmailAddressValidator.h"

@implementation SPEmailAddressValidator

+ (BOOL)stringIsValidPartialEmailAddress:(nullable NSString *)string {
  return [[string mutableCopy]
             replaceOccurrencesOfString:@"@"
                             withString:@""
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, string.length)] <= 1;
}

+ (BOOL)stringIsValidEmailAddress:(NSString *)string {
  if (!string) {
    return NO;
  }
  // regex from http://www.regular-expressions.info/email.html
  NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/"
                      @"=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+["
                      @"a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
  NSPredicate *predicate =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
  return [predicate evaluateWithObject:[string lowercaseString]];
}

@end
