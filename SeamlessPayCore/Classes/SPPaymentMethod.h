//
//  SPPaymentMethod.h
//  SeamlessPayCore
//

#import <Foundation/Foundation.h>
/**
 *  A token returned from submitting payment details to the SeamlessPay API. You should not have to instantiate one of these directly.
 */
@interface SPPaymentMethod : NSObject

/**
 *  Token of given payment data.
 */
@property (nonatomic, readonly, copy) NSString *token;
/**
 *  TName as it appears on card..
 */
@property (nonatomic, readonly, copy) NSString *name;
/**
 *  PAN Vault support five types of payments "Credit Card", "PINLess Debit Card", "ACH", "Gift Card"
 *  enum: CREDIT_CARD, PLDEBIT_CARD, ACH, GIFT_CARD
 */
@property (nonatomic, readonly, copy) NSString *txnType;
/**
 *  Last four of account number.
 */
@property (nonatomic, readonly, copy) NSString *lastfour;
/**
 *  Expiration Date.
 */
@property (nonatomic, readonly, copy) NSString *expDate;
/**
 * Bank account type: "Checking" "Savings"
 */
@property (nonatomic, readonly, copy) NSString *bankAccountType;
/**
 *Bank routing number
 */
@property (nonatomic, readonly, copy) NSString *routingNumber;
/**
 * Gift card PIN.
*/
@property (nonatomic, readonly, copy) NSString *pinNumber;


@property (nonatomic, readonly, copy) NSString *billingAddress;
@property (nonatomic, readonly, copy) NSString *billingAddress2;
@property (nonatomic, readonly, copy) NSString *billingCity;
@property (nonatomic, readonly, copy) NSString *billingState;
@property (nonatomic, readonly, copy) NSString *billingZip;
@property (nonatomic, readonly, copy) NSString *phoneNumber;
@property (nonatomic, readonly, copy) NSString *email;
@property (nonatomic, readonly, copy) NSString *company;
@property (nonatomic, readonly, copy) NSString *nickname;









+ (instancetype)tokenWithResponseData:(NSData * )data;
- (instancetype)initWithResponseData:(NSData * )data;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary*)dictionary;

@end
