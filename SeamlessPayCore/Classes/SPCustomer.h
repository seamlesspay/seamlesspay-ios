/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import <Foundation/Foundation.h>
#import "SPAddress.h"
#import "SPPaymentMethod.h"

@interface SPCustomer : NSObject
/**
 * Unique identifier for the object.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable customerId;
/**
 * The customer's name.
 */
@property(nonatomic, readonly, copy) NSString * _Nonnull  name;
/**
 * Customer email.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable email;
/**
 * The customer's first address
 */
@property(nonatomic, readonly, copy) SPAddress * _Nullable address;
/**
 *  The customer's company name.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable companyName;
/**
 *  The customer's notes.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable notes;
/**
 *  Custom json object
 */
@property(nonatomic, readonly, copy) NSString * _Nullable metadata;
/**
 *   The customer's phone number.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable phone;
/**
 *  The customer's payment methods.
 *   NSArray of objects (SPPaymentMethod)
 */
@property(nonatomic, readonly, copy) NSArray * _Nullable paymentMethods;
/**
 *   The customer's website.
 */
@property(nonatomic, readonly, copy) NSString * _Nullable website;
/**
 *   The customer's created.
 *   string <date-time>
 */
@property(nonatomic, readonly, copy) NSString * _Nullable createdAt;
/**
 *   The customer's updated.
 *   string <date-time>
 */
@property(nonatomic, readonly, copy) NSString * _Nullable updatedAt;


/**
 * Initializes instance of SPCustomer .
 */
+ (instancetype _Nonnull )customerWithResponseData:(nonnull NSData *)data;
- (instancetype _Nonnull )initWithResponseData:(nonnull NSData *)data;
- (instancetype _Nonnull )initWithName:(nonnull NSString *)name
                                 email:(nullable NSString *)email
                                 phone:(nullable NSString *)phone
                           companyName:(nullable NSString *)companyName
                                 notes:(nullable NSString *)notes
                               website:(nullable NSString *)website
                              metadata:(nullable NSString *)metadata
                               address:(nullable SPAddress *)address
                        paymentMethods:(nullable NSArray *)paymentMethods;

- (NSDictionary *_Nullable) dictionary;

@end
