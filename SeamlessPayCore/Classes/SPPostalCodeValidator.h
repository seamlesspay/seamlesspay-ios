//
//  SPPostalCodeValidator.h
//

#import <Foundation/Foundation.h>
#import "SPCardValidationState.h"

typedef NS_ENUM(NSUInteger, SPPostalCodeIntendedUsage) {
    SPPostalCodeIntendedUsageBillingAddress,
    SPPostalCodeIntendedUsageShippingAddress,
};

@interface SPPostalCodeValidator : NSObject
+ (BOOL)postalCodeIsRequiredForCountryCode:(nullable NSString *)countryCode;
+ (SPCardValidationState)validationStateForPostalCode:(nullable NSString *)postalCode
                                           countryCode:(nullable NSString *)countryCode;

+ (nullable NSString *)formattedSanitizedPostalCodeFromString:(nullable NSString *)postalCode
                                                  countryCode:(nullable NSString *)countryCode
                                                        usage:(SPPostalCodeIntendedUsage)usage;
@end
