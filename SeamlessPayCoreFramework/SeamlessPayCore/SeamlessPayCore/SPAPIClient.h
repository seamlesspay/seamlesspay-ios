//
//  SPAPIClient.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>
#import "SPPaymentMethod.h"
#import "SPCharge.h"
#import "SPCustomer.h"
#import "SMPError.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ParamSuccessBlock) (NSDictionary * _Nonnull);
typedef void (^ChargeSuccessBlock) (SPCharge * _Nonnull);
typedef void (^PaymentMethodBlock) (SPPaymentMethod * _Nonnull);
typedef void (^CustomerSuccessBlock) (SPCustomer * _Nonnull);
typedef void (^FailureBlock) (SMPError * _Nonnull);

@interface SPAPIClient : NSObject

@property(nullable, nonatomic, readonly, copy) NSString *secretKey;
@property(nullable, nonatomic, readonly, copy) NSString *publishableKey;

+ (instancetype)getSharedInstance NS_SWIFT_NAME(getSharedInstance());

- (void)setSecretKey:(NSString*)secretKey
      publishableKey:(NSString*)publicKey
             sandbox:(BOOL)sandbox;

/**
 * List Charges
 */
- (void)listChargesWithParams:(NSDictionary*)params
                      success:(nullable ParamSuccessBlock)success
                      failure:(nullable FailureBlock)failure;

/**
 * Create a Charge
 */
- (void)createChargeWithToken:(NSString*)token
                          cvv:(NSString*_Nullable)cvv
                      capture:(BOOL)capture
                     currency:(NSString*_Nullable)currency
                       amount:(NSString*)amount
                    taxAmount:(NSString*_Nullable)taxAmount
                    taxExempt:(BOOL)taxExempt
                          tip:(NSString*_Nullable)tip
           surchargeFeeAmount:(NSString*_Nullable)surchargeFeeAmount
            scheduleIndicator:(NSString*_Nullable)scheduleIndicator
                  description:(NSString*_Nullable)description
                        order:(NSDictionary*_Nullable)order
                      orderId:(NSString*_Nullable)orderId
                     poNumber:(NSString*_Nullable)poNumber
                     metadata:(NSDictionary*_Nullable)metadata
                   descriptor:(NSString*_Nullable)descriptor
                       txnEnv:(NSString*_Nullable)txnEnv
                      achType:(NSString*_Nullable)achType
          credentialIndicator:(NSString*_Nullable)credentialIndicator
        transactionInitiation:(NSString*_Nullable)transactionInitiation
               idempotencyKey:(NSString*_Nullable)idempotencyKey
              needSendReceipt:(BOOL)needSendReceipt
                      success:(_Nullable ChargeSuccessBlock)success
                      failure:(_Nullable FailureBlock)failure;

/**
 *  Retrieve a Charge
 */
- (void)retrieveChargeWithId:(NSString*)chargeId
                       success:(nullable ChargeSuccessBlock)success
                       failure:(nullable FailureBlock)failure;


/**
 *  Create the token of given payment data. Get token method require type of given object
 */
- (void)createPaymentMethodWithType:(NSString*)txnType
                            account:(NSString*_Nullable)account
                            expDate:(NSString*_Nullable)expDate
                        accountType:(NSString*_Nullable)accountType
                            routing:(NSString*_Nullable)routing
                                pin:(NSString*_Nullable)pin
                            address:(NSString*_Nullable)address
                           address2:(NSString*_Nullable)address2
                               city:(NSString*_Nullable)city
                            country:(NSString*_Nullable)country
                              state:(NSString*_Nullable)state
                                zip:(NSString*_Nullable)zip
                            company:(NSString*_Nullable)company
                              email:(NSString*_Nullable)email
                              phone:(NSString*_Nullable)phone
                               name:(NSString*_Nullable)name
                           nickname:(NSString*_Nullable)nickname
                            success:(nullable PaymentMethodBlock)success
                            failure:(nullable FailureBlock)failure;

/**
 *  Create a Customer
 */
- (void)createCustomerWithName:(NSString*_Nullable)name
                         email:(NSString*_Nullable)email
                       address:(NSString*_Nullable)address
                      address2:(NSString*_Nullable)address2
                          city:(NSString*_Nullable)city
                       country:(NSString*_Nullable)country
                         state:(NSString*_Nullable)state
                           zip:(NSString*_Nullable)zip
                       company:(NSString*_Nullable)company
                         phone:(NSString*_Nullable)phone
                       website:(NSString*_Nullable)website
                paymentMethods:(NSArray*_Nullable)paymentMethods
                      metadata:(NSDictionary*_Nullable)metadata
                       success:(nullable CustomerSuccessBlock)success
                       failure:(nullable FailureBlock)failure;

/**
 *  Update a Customer
 */
- (void)updateCustomerWithId:(NSString*)custId
                        name:(NSString*_Nullable)name
                       email:(NSString*_Nullable)email
                     address:(NSString*_Nullable)address
                    address2:(NSString*_Nullable)address2
                        city:(NSString*_Nullable)city
                     country:(NSString*_Nullable)country
                       state:(NSString*_Nullable)state
                         zip:(NSString*_Nullable)zip
                     company:(NSString*_Nullable)company
                       phone:(NSString*_Nullable)phone
                     website:(NSString*_Nullable)website
              paymentMethods:(NSArray*_Nullable)paymentMethods
                    metadata:(NSDictionary*_Nullable)metadata
                     success:(nullable CustomerSuccessBlock)success
                     failure:(nullable FailureBlock)failure;

/**
 *  Retrieve a Customer
 */
- (void)retrieveCustomerWithId:(NSString*)custId
                       success:(nullable CustomerSuccessBlock)success
                       failure:(nullable FailureBlock)failure;

@end
    
NS_ASSUME_NONNULL_END
