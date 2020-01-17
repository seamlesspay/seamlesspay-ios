//
//  SPPaymentMethodCardParams.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPPaymentMethodCardParams.h"

#import "SPCardParams.h"


@implementation SPPaymentMethodCardParams


- (instancetype)initWithCardSourceParams:(SPCardParams *)cardSourceParams {
    self = [self init];
    if (self) {
        _number = [cardSourceParams.number copy];
        _expMonth = @(cardSourceParams.expMonth);
        _expYear = @(cardSourceParams.expYear);
        _cvc = [cardSourceParams.cvc copy];
    }

    return self;
}

#pragma mark - Description

- (NSString *)description {
    NSArray *props = @[
                       // Object
                       [NSString stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],
                       
                       // Basic card details
                       [NSString stringWithFormat:@"last4 = %@", self.last4],
                       [NSString stringWithFormat:@"expMonth = %@", self.expMonth],
                       [NSString stringWithFormat:@"expYear = %@", self.expYear],
                       [NSString stringWithFormat:@"cvc = %@", (self.cvc) ? @"<redacted>" : nil],
                       
                       // Token
                       [NSString stringWithFormat:@"token = %@", self.token],
                       ];
    
    return [NSString stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}

- (NSString *)last4 {
    if (self.number && self.number.length >= 4) {
        return [self.number substringFromIndex:(self.number.length - 4)];
    } else {
        return nil;
    }
}

#pragma mark - SPFormEncodable


+ (NSString *)rootObjectName {
    return @"card";
}

+ (NSDictionary *)propertyNamesToFormFieldNamesMapping {
    return @{
             NSStringFromSelector(@selector(number)): @"number",
             NSStringFromSelector(@selector(expMonth)): @"exp_month",
             NSStringFromSelector(@selector(expYear)): @"exp_year",
             NSStringFromSelector(@selector(cvc)): @"cvc",
             NSStringFromSelector(@selector(token)): @"token",
             };
}




@end
