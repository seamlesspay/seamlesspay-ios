//
//  SPCardParams.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPCardParams.h"
#import "SPCard+Extras.h"

#import "SPCardValidator.h"

@implementation SPCardParams


- (instancetype)init {
    self = [super init];
    if (self) {
        _address = [SPAddress new];
    }
    return self;
}

- (NSString *)last4 {
    if (self.number && self.number.length >= 4) {
        return [self.number substringFromIndex:(self.number.length - 4)];
    } else {
        return nil;
    }
}

- (void)setName:(NSString *)name {
    _name = [name copy];
    self.address.name = self.name;
}

- (void)setAddress:(SPAddress *)address {
    _address = address;
    _name = [address.name copy];
}

#pragma mark - Description

- (NSString *)description {
    NSArray *props = @[
                       // Object
                       [NSString stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],

                       // Basic card details
                       [NSString stringWithFormat:@"last4 = %@", self.last4],
                       [NSString stringWithFormat:@"expMonth = %lu", (unsigned long)self.expMonth],
                       [NSString stringWithFormat:@"expYear = %lu", (unsigned long)self.expYear],
                       [NSString stringWithFormat:@"cvc = %@", (self.cvc) ? @"<redacted>" : nil],

                       // Additional card details (alphabetical)
                       [NSString stringWithFormat:@"currency = %@", self.currency],

                       // Cardholder details
                       [NSString stringWithFormat:@"name = %@", (self.name) ? @"<redacted>" : nil],
                       [NSString stringWithFormat:@"address = %@", (self.address) ? @"<redacted>" : nil],
                       ];

    return [NSString stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}


+ (NSString *)rootObjectName {
    return @"card";
}


@end
