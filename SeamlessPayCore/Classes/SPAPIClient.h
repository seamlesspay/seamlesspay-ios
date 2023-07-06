/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCharge.h"
#import "SPCustomer.h"
#import "SPError.h"
#import "SPAddress.h"
#import "SPPaymentMethod.h"
#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

/**
 List of available environments
 */
typedef NS_ENUM(NSUInteger, SPEnvironment) {
  SPEnvironmentSandbox,
  SPEnvironmentProduction,
  SPEnvironmentStaging,
  SPEnvironmentQAT,
};

typedef NS_ENUM(NSUInteger, SPPaymentType) {
  SPPaymentTypeAch,
  SPPaymentTypeCreditCard,
  SPPaymentTypeGiftCard,
  SPPaymentTypePlDebitCard,
};

@interface SPAPIClient : NSObject

@property(nonatomic, readonly, copy) NSString * _Nullable secretKey;
@property(nonatomic, readonly, copy) NSString * _Nonnull publishableKey;
@property(nonatomic, readonly, copy) NSString * _Nullable subMerchantAccountID;

+ (instancetype _Nonnull )getSharedInstance NS_SWIFT_NAME(getSharedInstance());

- (void)setSecretKey:(NSString *_Nullable)secretKey
      publishableKey:(NSString *_Nonnull)publishableKey
         environment:(SPEnvironment)environment;

- (void)setSubMerchantAccountID:(NSString *_Nullable)subMerchantAccountID;
     
/**
 * List Charges
 */
- (void)listChargesWithParams:(NSDictionary *_Nonnull)params
                      success:(void (^_Nonnull)(NSDictionary * _Nullable dict))success
                      failure:(void (^_Nonnull)(SPError *_Nonnull))failure;

/**
 * Create a Charge
 */
- (void)createChargeWithToken:(NSString *_Nonnull)token
                          cvv:(NSString *_Nullable)cvv
                      capture:(BOOL)capture
                     currency:(NSString *_Nullable)currency
                       amount:(NSString *_Nullable)amount
                    taxAmount:(NSString *_Nullable)taxAmount
                    taxExempt:(BOOL)taxExempt
                          tip:(NSString *_Nullable)tip
           surchargeFeeAmount:(NSString *_Nullable)surchargeFeeAmount
                  description:(NSString *_Nullable)description
                        order:(NSDictionary *_Nullable)order
                      orderId:(NSString *_Nullable)orderId
                     poNumber:(NSString *_Nullable)poNumber
                     metadata:(NSString *_Nullable)metadata
                   descriptor:(NSString *_Nullable)descriptor
                    entryType:(NSString *_Nullable)entryType
               idempotencyKey:(NSString *_Nullable)idempotencyKey
     digitalWalletProgramType:(NSString *_Nullable)digitalWalletProgramType
                      success:(void (^_Nonnull)(SPCharge *_Nonnull charge))success
                      failure:(void (^_Nonnull)(SPError *_Nonnull))failure;

/**
 *  Retrieve a Charge
 */
- (void)retrieveChargeWithId:(NSString *_Nonnull)chargeId
                     success:(void (^_Nonnull)(SPCharge *_Nullable charge))success
                     failure:(void (^_Nonnull)(SPError *_Nonnull))failure;

/**
 *  Create the token of given payment data. Get token method require type of
 *  given object
 */

- (void)tokenizeWithPaymentType:(SPPaymentType)paymentType
                        account:(NSString *_Nullable)account
                        expDate:(NSString *_Nullable)expDate
                            cvv:(NSString *_Nullable)cvv
                    accountType:(NSString *_Nullable)accountType
                        routing:(NSString *_Nullable)routing
                            pin:(NSString *_Nullable)pin
                 billingAddress:(SPAddress *_Nullable)billingAddress
             billingCompanyName:(NSString *_Nullable)billingCompany
                   accountEmail:(NSString *_Nullable)accountEmail
                    phoneNumber:(NSString *_Nullable)phoneNumber
                           name:(NSString *_Nullable)name
                       customer:(SPCustomer *_Nullable)customer
                        success:(void (^_Nonnull)(SPPaymentMethod *_Nonnull paymentMethod))success
                        failure:(void (^_Nonnull)(SPError *_Nonnull))failure;


/**
 *  Create a Customer
 */
- (void)createCustomerWithName:(NSString *_Nonnull)name
                         email:(NSString *_Nonnull)email
                       address:(SPAddress *_Nullable)address
                   companyName:(NSString *_Nullable)companyName
                         notes:(NSString *_Nullable)notes
                         phone:(NSString *_Nullable)phone
                       website:(NSString *_Nullable)website
                paymentMethods:(NSArray *_Nullable)paymentMethods
                      metadata:(NSString *_Nullable)metadata
                       success:(void (^_Nonnull)(SPCustomer *_Nonnull customer))success
                       failure:(void (^_Nonnull)(SPError *_Nonnull))failure;

/**
 *  Update a Customer
 */
- (void)updateCustomerWithId:(NSString *_Nonnull)customerId
                        name:(NSString *_Nonnull)name
                       email:(NSString *_Nonnull)email
                     address:(SPAddress *_Nullable)address
                 companyName:(NSString *_Nullable)companyName
                       notes:(NSString *_Nullable)notes
                       phone:(NSString *_Nullable)phone
                     website:(NSString *_Nullable)website
              paymentMethods:(NSArray *_Nullable)paymentMethods
                    metadata:(NSString *_Nullable)metadata
                     success:(void (^_Nonnull)(SPCustomer *_Nonnull customer))success
                     failure:(void (^_Nonnull)(SPError *_Nonnull))failure;

/**
 *  Retrieve a Customer
 */
- (void)retrieveCustomerWithId:(NSString *_Nonnull)customerId
                       success:(void (^_Nonnull)(SPCustomer *_Nullable customer))success
                       failure:(void (^_Nonnull)(SPError *_Nonnull))failure;

@end
