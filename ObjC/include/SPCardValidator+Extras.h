/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCardValidator (Extras)

+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END

void linkSPCardValidatorPrivateCategory(void);
