//
//  SPCardValidator+Extras.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPCardValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCardValidator (Extras)

+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END

void linkSPCardValidatorPrivateCategory(void);
