//
//  SPBINRange.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>
#import "SPCardBrand.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPBINRange : NSObject

@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) SPCardBrand brand;

+ (NSArray<SPBINRange *> *)allRanges;
+ (NSArray<SPBINRange *> *)binRangesForNumber:(NSString *)number;
+ (NSArray<SPBINRange *> *)binRangesForBrand:(SPCardBrand)brand;
+ (instancetype)mostSpecificBINRangeForNumber:(NSString *)number;

@end

NS_ASSUME_NONNULL_END
