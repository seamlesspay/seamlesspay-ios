/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
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
 *  TName as it appears on card..
 */
@property(nonatomic, readonly, copy) NSString *name;

/**
 *  PAN Vault support five types of payments "Credit Card", "PINLess Debit
 *  Card", "ACH", "Gift Card" enum: CREDIT_CARD, PLDEBIT_CARD, ACH, GIFT_CARD
 */
@property(nonatomic, readonly, copy) NSString *txnType;

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
 *  AVS Result Enum: "SM" "ZD" "SD" "ZM" "NS" "SE" "GN"
 */
@property(nonatomic, readonly, copy) NSString *avsResult;

/**
 *  CVV Result Enum: "M" "N" "P" "S" "U" "X"
 */
@property(nonatomic, readonly, copy) NSString *cvvResult;

/**
 *  Verification Result:  Enum: "verification_successful" "verification_failed"
 */
@property(nonatomic, readonly, copy) NSString *verificationResult;

/**
 * Gift card PIN.
 */
@property(nonatomic, readonly, copy) NSString *pinNumber;
@property(nonatomic, readonly, copy) NSString *billingAddress;
@property(nonatomic, readonly, copy) NSString *billingAddress2;
@property(nonatomic, readonly, copy) NSString *billingCity;
@property(nonatomic, readonly, copy) NSString *billingState;
@property(nonatomic, readonly, copy) NSString *billingZip;
@property(nonatomic, readonly, copy) NSString *phoneNumber;
@property(nonatomic, readonly, copy) NSString *email;
@property(nonatomic, readonly, copy) NSString *company;
@property(nonatomic, readonly, copy) NSString *nickname;

+ (instancetype)tokenWithResponseData:(NSData *)data;
- (instancetype)initWithResponseData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

@end
