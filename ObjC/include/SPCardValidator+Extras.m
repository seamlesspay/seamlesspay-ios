/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardValidator+Extras.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SPCardValidator (Extras)

+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(SPCardBrand)brand {
  switch (brand) {
    case SPCardBrandAmex:
      return @[ @4, @6, @5 ];
    case SPCardBrandDinersClub:
      return @[ @4, @6, @4 ];
    default:
      return @[ @4, @4, @4, @4 ];
  }
}

@end

NS_ASSUME_NONNULL_END

void linkSPCardValidatorPrivateCategory(void) {}
