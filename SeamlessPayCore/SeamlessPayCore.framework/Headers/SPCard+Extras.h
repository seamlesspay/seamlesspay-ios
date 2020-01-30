/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCard ()

+ (SPCardFundingType)fundingFromString:(NSString *)string;
+ (nullable NSString *)stringFromFunding:(SPCardFundingType)funding;
+ (NSString *)stringFromBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END
