/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardValidator+Extras.h"
#import "SPBINRange.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SPCardValidator (Extras)

+ (NSArray<NSNumber *> *)cardNumberFormatCardNumber:(NSString *)cardNumber {
  NSString *sanitizedNumber = [self sanitizedNumericStringForString:cardNumber];
  SPBINRange *definedBINRangeForNumber = [SPBINRange definedBINRangeForNumber:sanitizedNumber];
  
  switch (definedBINRangeForNumber.length) {
    case 15:
      return @[ @4, @6, @5 ];
    case 14:
      return @[ @4, @6, @4 ];
    default:
      return @[ @4, @4, @4, @4 ];
  }
}

@end

NS_ASSUME_NONNULL_END

void linkSPCardValidatorPrivateCategory(void) {}
