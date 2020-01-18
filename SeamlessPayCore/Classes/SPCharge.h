//
//  SPCharge.h
//  SeamlessPayCore
//
//  Created by Stanislav Butkovskiy on 1/07/20.
//  Copyright © 2020 Datasub. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPCharge : NSObject

/**
 * The ID of base charge.
 */
@property(nonatomic, readonly, copy) NSString *chargeId;
/**
 * Value: "charge"  Transaction method
 */
@property(nonatomic, readonly, copy) NSString *method;
/**
 * Amount to add to stored value account.
 */
@property(nonatomic, readonly, copy) NSString *amount;
/**
 *
 */
@property(nonatomic, readonly, copy) NSString *tip;
/**
 * Surcharge fee amount.
 */
@property(nonatomic, readonly, copy) NSString *surchargeFeeAmount;
/**
 * Order dictionary
 */
@property(nonatomic, readonly, copy) NSDictionary *order;
/**
 * Currency:  USD - United States dollar.  CAD - Canadian dollar.
 */
@property(nonatomic, readonly, copy) NSString *currency;
/**
 * Detail Card Product - Visa, MasterCard, American Express, Discover.
 */
@property(nonatomic, readonly, copy) NSString *cardBrand;
/**
 * Determines the card type (credit, debit, prepaid) and usage (pin, signature etc.).
 */
@property(nonatomic, readonly, copy) NSString *cardType;
/**
 * Last four of account number.
 */
@property(nonatomic, readonly, copy) NSString *lastFour;
/**
 * The payment method (token) from pan-vault
 */
@property(nonatomic, readonly, copy) NSString *token;
/**
 * Transaction date
 */
@property(nonatomic, readonly, copy) NSString *txnDate;
/**
 * Transaction status "AUTHORIZED" "CAPTURED" "DECLINED" "ERROR"
 */
@property(nonatomic, readonly, copy) NSString *status;
/**
 * Transaction status code (See all available transaction status codes https://docs.seamlesspay.com/#section/Transaction-Statuses  ).
 */
@property(nonatomic, readonly, copy) NSString *statusCode;
/**
 * Transaction status description.
 */
@property(nonatomic, readonly, copy) NSString *statusDescription;
/**
 * AVS Result: "SM" "ZD" "SD" "ZM" "NS" "SE" "GN"
 */
@property(nonatomic, readonly, copy) NSString *avsResult;
/**
 * AVS Message: "street match" "street decline" "zip match" "zip decline" "AVS not supported" "system error - retry" "global non-AVS participant"
 */
@property(nonatomic, readonly, copy) NSString *avsMessage;
/**
 * CVV Result: "M" "N" "P" "S" "U" "X"
 */
@property(nonatomic, readonly, copy) NSString *cvvResult;
/**
 * IP address
 */
@property(nonatomic, readonly, copy) NSString *ipAddress;
/**
 * Auth Code
 */
@property(nonatomic, readonly, copy) NSString *authCode;
/**
 * Batch ID
 */
@property(nonatomic, readonly, copy) NSString *batch;
/**
 *  Aadjustments
*/
@property(nonatomic, readonly, copy) NSArray *adjustments;
/**
 *  Business Card
*/
@property(nonatomic, readonly) BOOL businessCard;

/**
 * Initializes instance of SPCharge with keys.
 */
- (instancetype)initWithResponseData:(NSData *)data;
+ (instancetype)chargeWithResponseData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end
