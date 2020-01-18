//
//  SPCardBrand.m
//

#import "SPCardBrand.h"

NSString * SPStringFromCardBrand(SPCardBrand brand) {
    switch (brand) {
        case SPCardBrandAmex:
            return @"American Express";
        case SPCardBrandDinersClub:
            return @"Diners Club";
        case SPCardBrandDiscover:
            return @"Discover";
        case SPCardBrandJCB:
            return @"JCB";
        case SPCardBrandMasterCard:
            return @"Mastercard";
        case SPCardBrandUnionPay:
            return @"UnionPay";
        case SPCardBrandVisa:
            return @"Visa";
        case SPCardBrandUnknown:
            return @"Unknown";
    }
}
