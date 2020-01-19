/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "NSString+Extras.h"

@implementation NSString (Extras)

- (NSString *)sp_safeSubstringToIndex:(NSUInteger)index {
  return [self substringToIndex:MIN(self.length, index)];
}

- (NSString *)sp_safeSubstringFromIndex:(NSUInteger)index {
  return (index > self.length) ? @"" : [self substringFromIndex:index];
}

- (NSString *)sp_reversedString {
  NSMutableString *mutableReversedString = [NSMutableString stringWithCapacity:self.length];
  [self
      enumerateSubstringsInRange:NSMakeRange(0, self.length)
                         options:(NSStringEnumerationOptions)(
                                 NSStringEnumerationReverse |
                                 NSStringEnumerationByComposedCharacterSequences)
                      usingBlock:^(NSString *substring,
                                   __unused NSRange substringRange,
                                   __unused NSRange enclosingRange,
                                   __unused BOOL *stop) {
                        [mutableReversedString appendString:substring];
                      }];
  return [mutableReversedString copy];
}

- (NSString *)sp_stringByRemovingSuffix:(NSString *)suffix {
  if (suffix != nil && [self hasSuffix:suffix]) {
    return [self sp_safeSubstringToIndex:self.length - suffix.length];
  } else {
    return [self copy];
  }
}

@end

void linkNSStringCategory(void) {}
