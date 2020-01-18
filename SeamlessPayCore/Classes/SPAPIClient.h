//
//  SPAPIClient.h
//  SeamlessPayCore
//

#import <Foundation/Foundation.h>
#import "SPPaymentMethod.h"
#import "SPCharge.h"
#import "SPCustomer.h"
#import "SPError.h"

@interface SPAPIClient : NSObject
@property(nonatomic, readonly, copy) NSString *secretKey;
@property(nonatomic, readonly, copy) NSString *publicKey;

+ (instancetype)getSharedInstance NS_SWIFT_NAME(getSharedInstance());

- (void)setSecretKey:(NSString*)secretKey
           publicKey:(NSString*)publicKey
             sandbox:(BOOL)sandbox;

/**
 * List Charges
 */
- (void)listChargesWithParams:(NSDictionary*)params
                      success:(void(^)(NSDictionary *dict))success
                      failure:(void(^)(SPError *))failure;

/**
 * Create a Charge
 */
- (void)createChargeWithToken:(NSString*)token
                          cvv:(NSString*)cvv
                      capture:(BOOL)capture
                     currency:(NSString*)currency
                       amount:(NSString*)amount
                    taxAmount:(NSString*)taxAmount
                    taxExempt:(BOOL)taxExempt
                          tip:(NSString*)tip
           surchargeFeeAmount:(NSString*)surchargeFeeAmount
            scheduleIndicator:(NSString*)scheduleIndicator
                  description:(NSString*)description
                        order:(NSDictionary*)order
                      orderId:(NSString*)orderId
                     poNumber:(NSString*)poNumber
                     metadata:(NSDictionary*)metadata
                   descriptor:(NSString*)descriptor
                       txnEnv:(NSString*)txnEnv
                      achType:(NSString*)achType
          credentialIndicator:(NSString*)credentialIndicator
        transactionInitiation:(NSString*)transactionInitiation
               idempotencyKey:(NSString*)idempotencyKey
              needSendReceipt:(BOOL)needSendReceipt
                      success:(void(^)(SPCharge *charge))success
                      failure:(void(^)(SPError *))failure;

/**
 *  Retrieve a Charge
 */
- (void)retrieveChargeWithId:(NSString*)chargeId
                       success:(void(^)(SPCharge *charge))success
                       failure:(void(^)(SPError *))failure;


/**
 *  Create the token of given payment data. Get token method require type of given object
 */
- (void)createPaymentMethodWithType:(NSString*)txnType
                            account:(NSString*)account
                            expDate:(NSString*)expDate
                        accountType:(NSString*)accountType
                            routing:(NSString*)routing
                                pin:(NSString*)pin
                            address:(NSString*)address
                           address2:(NSString*)address2
                               city:(NSString*)city
                            country:(NSString*)country
                              state:(NSString*)state
                                zip:(NSString*)zip
                            company:(NSString*)company
                              email:(NSString*)email
                              phone:(NSString*)phone
                               name:(NSString*)name
                           nickname:(NSString*)nickname
                            success:(void(^)(SPPaymentMethod *paymentMethod))success
                            failure:(void(^)(SPError *))failure;

/**
 *  Create a Customer
 */
- (void)createCustomerWithName:(NSString*)name
                         email:(NSString*)email
                       address:(NSString*)address
                      address2:(NSString*)address2
                          city:(NSString*)city
                       country:(NSString*)country
                         state:(NSString*)state
                           zip:(NSString*)zip
                       company:(NSString*)company                        
                         phone:(NSString*)phone
                       website:(NSString*)website
                paymentMethods:(NSArray*)paymentMethods
                      metadata:(NSDictionary*)metadata
                       success:(void(^)(SPCustomer *customer))success
                       failure:(void(^)(SPError *))failure;

/**
 *  Update a Customer
 */
- (void)updateCustomerWithId:(NSString*)custId
                        name:(NSString*)name
                       email:(NSString*)email
                     address:(NSString*)address
                    address2:(NSString*)address2
                        city:(NSString*)city
                     country:(NSString*)country
                       state:(NSString*)state
                         zip:(NSString*)zip
                     company:(NSString*)company
                       phone:(NSString*)phone
                     website:(NSString*)website
              paymentMethods:(NSArray*)paymentMethods
                    metadata:(NSDictionary*)metadata
                     success:(void(^)(SPCustomer *customer))success
                     failure:(void(^)(SPError *))failure;

/**
 *  Retrieve a Customer
 */
- (void)retrieveCustomerWithId:(NSString*)custId
                       success:(void(^)(SPCustomer *customer))success
                       failure:(void(^)(SPError *))failure;

@end
    
