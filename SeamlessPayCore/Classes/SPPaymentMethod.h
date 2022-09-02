/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "SPAddress.h"

/**
 *  A token returned from submitting payment details to the SeamlessPay API. You
 *  should not have to instantiate one of these directly.
 */
@interface SPPaymentMethod : NSObject

/**
 *  Token of given payment data.
 */
@property(nonatomic, readonly, copy) NSString *token;

/**
 *  Name as it appears on card..
 */
@property(nonatomic, readonly, copy) NSString *name;

@property(nonatomic, readonly, copy) NSString *nickname;

/**
 *  PAN Vault support five types of payments "Credit Card", "PINLess Debit
 *  Card", "ACH", "Gift Card" enum: credit_card, pldebit_card, ach, gift_card
 */
@property(nonatomic, readonly, copy) NSString *paymentType;

/**
 *  Last four of account number.
 */
@property(nonatomic, readonly, copy) NSString *lastfour;

/**
 *  Expiration Date.
 */
@property(nonatomic, readonly, copy) NSString *expDate;

/**
 *  Bank account type: "Checking" "Savings"
 */
@property(nonatomic, readonly, copy) NSString *bankAccountType;

/**
 *  Bank routing number
 */
@property(nonatomic, readonly, copy) NSString *routingNumber;

/**
 Verification (Dictionary):
 
 addressLine1 =>  (string) "pass" "fail" "unchecked" "unsupported" "retry"
 AVS Verification Code (See all AVS verification codes)

 addressPostalCode => ( string)  "pass" "fail" "unchecked" "unsupported" "retry"
 AVS Verification Code (See all AVS verification codes)

 cvv => (string) "pass" "fail" "unchecked" "unsupported" "retry"
 CVV Verification Code (See all CVV verification codes)
 */

@property(nonatomic, readonly, copy) NSDictionary *verification;

/**
 * Gift card PIN.
 */
@property(nonatomic, readonly, copy) NSString *pinNumber;
/**
 *  The various card brands to which a payment card can belong.
 */
@property(nonatomic, readonly, copy) NSString *paymentNetwork;
@property(nonatomic, readonly, copy) SPAddress *billingAddress;
@property(nonatomic, readonly, copy) NSString *phoneNumber;
@property(nonatomic, readonly, copy) NSString *email;
@property(nonatomic, readonly, copy) NSString *company;
@property(nonatomic, readonly, copy) NSString *customerId;

+ (instancetype)tokenWithResponseData:(NSData *)data;
- (instancetype)initWithResponseData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

@end
