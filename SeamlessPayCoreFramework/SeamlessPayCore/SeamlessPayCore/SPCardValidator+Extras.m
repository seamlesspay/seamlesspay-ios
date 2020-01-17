//
//  SPCardValidator+Extras.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPCardValidator+Extras.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SPCardValidator (Extras)

+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(SPCardBrand)brand
{
    switch (brand) {
        case SPCardBrandAmex:
            return @[@4, @6, @5];
        case SPCardBrandDinersClub:
            return @[@4, @6, @4];
        default:
            return @[@4, @4, @4, @4];
    }
}

@end

NS_ASSUME_NONNULL_END

void linkSPCardValidatorPrivateCategory(void){}
