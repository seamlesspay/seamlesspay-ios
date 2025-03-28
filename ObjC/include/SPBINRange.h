/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardBrand.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPBINRange : NSObject

@property(nonatomic, readonly) NSUInteger length;
@property(nonatomic, readonly) SPCardBrand brand;

+ (NSArray<SPBINRange *> *)binRangesForBrand:(SPCardBrand)brand;
+ (instancetype)definedBINRangeForNumber:(NSString *)number;
+ (BOOL)isPotentialBINRangesExistForNumber:(NSString *)number;

@end

NS_ASSUME_NONNULL_END
