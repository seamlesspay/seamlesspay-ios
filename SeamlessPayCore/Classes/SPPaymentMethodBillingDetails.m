//
//  SPPaymentMethodBillingDetails.m
//

#import "SPPaymentMethodBillingDetails.h"

#import "SPPaymentMethodAddress.h"
#import "NSDictionary+Extras.h"

@interface SPPaymentMethodBillingDetails ()

@property (nonatomic, copy, nonnull, readwrite) NSDictionary *allResponseFields;

@end

@implementation SPPaymentMethodBillingDetails

- (NSString *)description {
    NSArray *props = @[
                        // Object
                        [NSString stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],
                        
                        // Properties
                        [NSString stringWithFormat:@"name = %@", self.name],
                        [NSString stringWithFormat:@"phone = %@", self.phone],
                        [NSString stringWithFormat:@"email = %@", self.email],
                        [NSString stringWithFormat:@"address = %@", self.address],
                        ];
    return [NSString stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}

#pragma mark - SPFormEncodable

+ (nonnull NSDictionary *)propertyNamesToFormFieldNamesMapping {
    return @{
             NSStringFromSelector(@selector(address)): @"address",
             NSStringFromSelector(@selector(email)): @"email",
             NSStringFromSelector(@selector(name)): @"name",
             NSStringFromSelector(@selector(phone)): @"phone",
             };
}

+ (nullable NSString *)rootObjectName {
    return nil;
}

@end
