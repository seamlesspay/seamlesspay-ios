//
//  SPCard+Extras.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCard ()


+ (SPCardFundingType)fundingFromString:(NSString *)string;
+ (nullable NSString *)stringFromFunding:(SPCardFundingType)funding;

+ (NSString *)stringFromBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END
