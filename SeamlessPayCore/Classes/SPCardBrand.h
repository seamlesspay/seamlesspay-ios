//
//  SPCardBrand.h
//

#import <Foundation/Foundation.h>

/**
 The various card brands to which a payment card can belong.
 */
typedef NS_ENUM(NSInteger, SPCardBrand) {

    /**
     Visa card
     */
    SPCardBrandVisa,

    /**
     American Express card
     */
    SPCardBrandAmex,

    /**
     Mastercard card
     */
    SPCardBrandMasterCard,

    /**
     Discover card
     */
    SPCardBrandDiscover,

    /**
     JCB card
     */
    SPCardBrandJCB,

    /**
     Diners Club card
     */
    SPCardBrandDinersClub,

    /**
     UnionPay card
     */
    SPCardBrandUnionPay,

    /**
     An unknown card brand type
     */
    SPCardBrandUnknown,
};



NSString * SPStringFromCardBrand(SPCardBrand brand);
