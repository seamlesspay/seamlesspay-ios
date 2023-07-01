//
//  SPCharge.h
//  SeamlessPayCore
//
//  Copyright © 2020 Seamless Payments, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPCharge : NSObject

/**
 * The ID of base charge.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable chargeId;//
/**
 * Value: "charge"  Transaction method
 */
@property(nonatomic, readonly, copy) NSString * _Nullable method;//
/**
 * Amount to add to stored value account.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable amount;//
/**
 * String with 2 decimal places e.g “25.00”.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable tip;//
/**
 * Surcharge fee amount. String with 2 decimal places e.g “25.00”.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable surchargeFeeAmount;//
/**
 * Order dictionary
 */
@property(nonatomic, readonly, copy) NSDictionary * _Nullable order;//
/**
 * Currency:  USD - United States dollar.  CAD - Canadian dollar.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable currency;//
/**
 * Card Expiration Date.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable expDate;//
/**
 * Last four of account number.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable lastFour;//
/**
 * The payment method (token) from pan-vault
 */
@property(nonatomic, readonly, copy) NSString * _Nullable token;//
/**
 * Transaction date string <date-time>
 */
@property(nonatomic, readonly, copy) NSString * _Nullable transactionDate;//
/**
 * Enum: "authorized" "captured" "declined" "error"  Transaction status
 */
@property(nonatomic, readonly, copy) NSString * _Nullable status;//
/**
 * Transaction status code (See all available transaction status codes https://docs.seamlesspay.com/#section/Transaction-Statuses  ).
 */
@property(nonatomic, readonly, copy) NSString * _Nullable statusCode;//
/**
 * Transaction status description.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable statusDescription;//
/**
 * IP address
 */
@property(nonatomic, readonly, copy) NSString * _Nullable ipAddress;//
/**
 * Auth Code
 */
@property(nonatomic, readonly, copy) NSString * _Nullable authCode;//
/**
 * Enum: "Credit" "Debit" "Prepaid"  Determines the card type (credit, debit, prepaid) and usage (pin, signature etc.).
 */
@property(nonatomic, readonly, copy) NSString * _Nullable accountType;//
/**
 * Payment type
 */
@property(nonatomic, readonly, copy) NSString * _Nullable paymentType;//
/**
 * Enum: "Visa" "MasterCard" "American Express" "Discover"  Detail Card Product - Visa, MasterCard, American Express, Discover.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable paymentNetwork;//
/**
 * Batch ID
 */
@property(nonatomic, readonly, copy) NSString * _Nullable batch;//
/**
 *  verification
*/
@property(nonatomic, readonly, copy) NSDictionary * _Nullable verification;//
/**
 *  Business Card
*/
@property(nonatomic, readonly) BOOL businessCard;//
/**
 *  Business Card
*/
@property(nonatomic, readonly) BOOL fullyRefunded;//
/**
 *  Array of Dictionary  List of refunds associated with the charge.
*/
@property(nonatomic, readonly, copy) NSArray * _Nullable refunds;
/**
 *  Array of Dictionary (ChargeAdjustment)  The charge adjustments.
*/
@property(nonatomic, readonly, copy) NSArray * _Nullable adjustments;
/**
 *   The customer's created.
 *   string <date-time>
 */
@property(nonatomic, readonly, copy) NSString * _Nullable createdAt;//
/**
 *   The customer's updated.
 *   string <date-time>
 */
@property(nonatomic, readonly, copy) NSString * _Nullable updatedAt;//

/**
 * Initializes instance of SPCharge with keys.
 */
- (instancetype _Nonnull )initWithResponseData:(nonnull NSData *)data;
+ (instancetype _Nonnull )chargeWithResponseData:(nonnull NSData *)data;
@end
