/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "SPCardBrand.h"

//@class SPPaymentMethodThreeDSecureUsage, SPPaymentMethodCardChecks,
// SPPaymentMethodCardWallet;

NS_ASSUME_NONNULL_BEGIN

/**
 Contains details about a user's credit card.
 */
@interface SPPaymentMethodCard : NSObject // <SPAPIResponseDecodable>

/**
 You cannot directly instantiate an `SPPaymentMethodCard`. You should only use
 one that is part of an existing `SPPaymentMethod` object.
 */
- (instancetype)init __attribute__((unavailable("You cannot directly instantiate an SPPaymentMethodCard. You should only "
                                                "use one that is part of an existing SPPaymentMethod object.")));

/**
 The issuer of the card.
 */
@property(nonatomic, readonly) SPCardBrand brand;

/**
 Checks on Card address and CVC if provided.
 */
//@property (nonatomic, nullable, readonly) SPPaymentMethodCardChecks *checks;

/**
 Two-letter ISO code representing the country of the card.
 */
@property(nonatomic, nullable, readonly) NSString *country;

/**
 Two-digit number representing the card’s expiration month.
 */
@property(nonatomic, readonly) NSInteger expMonth;

/**
 Four-digit number representing the card’s expiration year.
 */
@property(nonatomic, readonly) NSInteger expYear;

/**
 Card funding type. Can be credit, debit, prepaid, or unknown.
 */
@property(nonatomic, nullable, readonly) NSString *funding;

/**
 The last four digits of the card.
 */
@property(nonatomic, nullable, readonly) NSString *last4;

/**
 Uniquely identifies this particular card number. You can use this attribute to
 check whether two customers who’ve signed up with you are using the same card
 number, for example.
 */
@property(nonatomic, nullable, readonly) NSString *fingerprint;

/**
 Contains details on how this Card maybe be used for 3D Secure authentication.
 */
//@property (nonatomic, nullable, readonly) SPPaymentMethodThreeDSecureUsage
//*threeDSecureUsage;

/**
 If this Card is part of a Card Wallet, this contains the details of the Card
 Wallet.
 */
//@property (nonatomic, nullable, readonly) SPPaymentMethodCardWallet *wallet;

/**
 Returns a string representation for the provided card brand;
 i.e. `[NSString stringFromBrand:SPCardBrandVisa] ==  @"Visa"`.

 @param brand the brand you want to convert to a string

 @return A string representing the brand, suitable for displaying to a user.
 */
+ (NSString *)stringFromBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END
