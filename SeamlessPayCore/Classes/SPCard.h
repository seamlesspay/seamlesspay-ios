//
//  SPCard.h
//
//

#import <Foundation/Foundation.h>

#import "SPCardBrand.h"
#import "SPCardParams.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The various funding sources for a payment card.
 */
typedef NS_ENUM(NSInteger, SPCardFundingType) {
    /**
     Debit card funding
     */
    SPCardFundingTypeDebit,

    /**
     Credit card funding
     */
    SPCardFundingTypeCredit,

    /**
     Prepaid card funding
     */
    SPCardFundingTypePrepaid,

    /**
     An other or unknown type of funding source.
     */
    SPCardFundingTypeOther,
};


@interface SPCard : NSObject 


- (instancetype) init __attribute__((unavailable("You cannot directly instantiate an SPCard. You should only use one that has been returned from an SPAPIClient callback.")));

/**
 The last 4 digits of the card.
 */
@property (nonatomic, readonly) NSString *last4;

@property (nonatomic, nullable, readonly) NSString *dynamicLast4;

@property (nonatomic, readonly) BOOL isApplePayCard;


@property (nonatomic, readonly) NSUInteger expMonth;


@property (nonatomic, readonly) NSUInteger expYear;

/**
 The cardholder's name.
 */
@property (nonatomic, nullable, readonly) NSString *name;

/**
 The cardholder's address.
 */
@property (nonatomic, readonly) SPAddress *address;

/**
 The issuer of the card.
 */
@property (nonatomic, readonly) SPCardBrand brand;


@property (nonatomic, readonly) SPCardFundingType funding;


@property (nonatomic, nullable, readonly) NSString *country;


@property (nonatomic, nullable, readonly) NSString *currency;


@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, NSString *> *metadata;


+ (NSString *)stringFromBrand:(SPCardBrand)brand;


+ (SPCardBrand)brandFromString:(NSString *)string;


+ (SPCardFundingType)fundingFromString:(NSString *)string DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
