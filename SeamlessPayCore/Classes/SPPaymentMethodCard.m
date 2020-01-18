//
//  SPPaymentMethodCard.m
//

#import "SPPaymentMethodCard.h"

#import "NSDictionary+Extras.h"

@interface SPPaymentMethodCard ()

@property (nonatomic, readwrite) SPCardBrand brand;
@property (nonatomic, copy, nullable, readwrite) NSString *country;
@property (nonatomic, readwrite) NSInteger expMonth;
@property (nonatomic, readwrite) NSInteger expYear;
@property (nonatomic, copy, nullable, readwrite) NSString *funding;
@property (nonatomic, copy, nullable, readwrite) NSString *last4;
@property (nonatomic, copy, nullable, readwrite) NSString *fingerprint;
@property (nonatomic, copy, nonnull, readwrite) NSDictionary *allResponseFields;

@end

@implementation SPPaymentMethodCard

- (NSString *)description {
    NSArray *props = @[
                       // Object
                       [NSString stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],
                       
                       [NSString stringWithFormat:@"brand = %@", SPStringFromCardBrand(self.brand)],
                                   [NSString stringWithFormat:@"country = %@", self.country],
                       [NSString stringWithFormat:@"expMonth = %lu", (unsigned long)self.expMonth],
                       [NSString stringWithFormat:@"expYear = %lu", (unsigned long)self.expYear],
                       [NSString stringWithFormat:@"funding = %@", self.funding],
                       [NSString stringWithFormat:@"last4 = %@", self.last4],
                       [NSString stringWithFormat:@"fingerprint = %@", self.fingerprint],
                       ];

    return [NSString stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}


#pragma mark - SPCardBrand

+ (NSString *)stringFromBrand:(SPCardBrand)brand {
    return SPStringFromCardBrand(brand);
}

+ (SPCardBrand)brandFromString:(NSString *)string {
 
    NSString *brand = [string lowercaseString];
    if ([brand isEqualToString:@"visa"]) {
        return SPCardBrandVisa;
    } else if ([brand isEqualToString:@"amex"]) {
        return SPCardBrandAmex;
    } else if ([brand isEqualToString:@"mastercard"]) {
        return SPCardBrandMasterCard;
    } else if ([brand isEqualToString:@"discover"]) {
        return SPCardBrandDiscover;
    } else if ([brand isEqualToString:@"jcb"]) {
        return SPCardBrandJCB;
    } else if ([brand isEqualToString:@"diners"]) {
        return SPCardBrandDinersClub;
    } else if ([brand isEqualToString:@"unionpay"]) {
        return SPCardBrandUnionPay;
    } else {
        return SPCardBrandUnknown;
    }
}

@end
