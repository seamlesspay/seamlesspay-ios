//
//  SPCard+Extras.h
//

#import "SPCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPCard ()


+ (SPCardFundingType)fundingFromString:(NSString *)string;
+ (nullable NSString *)stringFromFunding:(SPCardFundingType)funding;

+ (NSString *)stringFromBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END
