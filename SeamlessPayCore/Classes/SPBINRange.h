//
//  SPBINRange.h
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
