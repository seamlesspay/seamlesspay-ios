//
//  SPCardValidator+Extras.h
//

#import "SPCardValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCardValidator (Extras)

+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END

void linkSPCardValidatorPrivateCategory(void);
