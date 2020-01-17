//
//  SPPaymentMethodAddress.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPPaymentMethodAddress.h"

#import "NSDictionary+Extras.h"
#import "SPAddress.h"

@interface SPPaymentMethodAddress ()

@property (nonatomic, copy, nonnull, readwrite) NSDictionary *allResponseFields;

@end

@implementation SPPaymentMethodAddress

- (instancetype)initWithAddress:(SPAddress *)address {
    self = [super init];
    if (self) {
        _city = [address.city copy];
        _country = [address.country copy];
        _line1 = [address.line1 copy];
        _line2 = [address.line2 copy];
        _postalCode = [address.postalCode copy];
        _state = [address.state copy];
    }
    return self;
}

- (NSString *)description {
    NSArray *props = @[
                       // Object
                       [NSString stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],
                       
                       // Properties
                       [NSString stringWithFormat:@"line1 = %@", self.line1],
                       [NSString stringWithFormat:@"line2 = %@", self.line2],
                       [NSString stringWithFormat:@"city = %@", self.city],
                       [NSString stringWithFormat:@"state = %@", self.state],
                       [NSString stringWithFormat:@"postalCode = %@", self.postalCode],
                       [NSString stringWithFormat:@"country = %@", self.country],
                       ];
    
    return [NSString stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}

#pragma mark - SPFormEncodable

//@synthesize additionalAPIParameters;

+ (nonnull NSDictionary *)propertyNamesToFormFieldNamesMapping {
    return @{
             NSStringFromSelector(@selector(line1)): @"line1",
             NSStringFromSelector(@selector(line2)): @"line2",
             NSStringFromSelector(@selector(city)): @"city",
             NSStringFromSelector(@selector(country)): @"country",
             NSStringFromSelector(@selector(state)): @"state",
             NSStringFromSelector(@selector(postalCode)): @"postal_code",
             };
}

+ (nullable NSString *)rootObjectName {
    return nil;
}

@end
