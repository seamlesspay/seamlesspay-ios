/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

#import "SPFormEncodable.h"

@class CNContact;
@class SPPaymentMethodBillingDetails;

NS_ASSUME_NONNULL_BEGIN

/**
 Billing address information you need to collect from your user.

 @note If the user is from a country that does not use zip/postal codes,
 the user may not be asked for one regardless of this setting.
 */
typedef NS_ENUM(NSUInteger, SPBillingAddressFields) {
  /**
   No billing address information
   */
  SPBillingAddressFieldsNone,
  /**
   Just request the user's billing ZIP code
   */
  SPBillingAddressFieldsZip,
  /**
   Request the user's full billing address
   */
  SPBillingAddressFieldsFull,
  /**
   Just request the user's billing name
   */
  SPBillingAddressFieldsName,
};

/**
 Constants that represent different parts of a users contact/address
 information.
 */
typedef NSString *SPContactField NS_STRING_ENUM;

/**
 The contact's full physical address.
 */
extern SPContactField const SPContactFieldPostalAddress;

/**
 The contact's email address.
 */
extern SPContactField const SPContactFieldEmailAddress;

/**
 The contact's phone number.
 */
extern SPContactField const SPContactFieldPhoneNumber;

/**
 The contact's name.
 */
extern SPContactField const SPContactFieldName;

/**
 SPAddress Contains an address
 */
@interface SPAddress : NSObject <SPFormEncodable, NSCopying>

/**
 The user's full name (e.g. "Jane Doe")
 */
@property(nonatomic, copy, nullable) NSString *name;

/**
 The first line of the user's street address (e.g. "123 Fake St")
 */
@property(nonatomic, copy, nullable) NSString *line1;

/**
 The apartment, floor number, etc of the user's street address (e.g. "Apartment
 1A")
 */
@property(nonatomic, copy, nullable) NSString *line2;

/**
 The city in which the user resides (e.g. "San Francisco")
 */
@property(nonatomic, copy, nullable) NSString *city;

/**
 The state in which the user resides (e.g. "CA")
 */
@property(nonatomic, copy, nullable) NSString *state;

/**
 The postal code in which the user resides (e.g. "90210")
 */
@property(nonatomic, copy, nullable) NSString *postalCode;

/**
 The ISO country code of the address (e.g. "US")
 */
@property(nonatomic, copy, nullable) NSString *country;

/**
 The phone number of the address (e.g. "8885551212")
 */
@property(nonatomic, copy, nullable) NSString *phone;

/**
 The email of the address (e.g. "jane@doe.com")
 */
@property(nonatomic, copy, nullable) NSString *email;

//+ (nullable NSDictionary *)
//shippingInfoForChargeWithAddress:(nullable SPAddress *)address
//shippingMethod:(nullable PKShippingMethod *)method;

//- (instancetype)initWithPaymentMethodBillingDetails:
//(SPPaymentMethodBillingDetails *)billingDetails;
//- (instancetype)initWithPKContact:(PKContact *)contact;
//- (PKContact *)PKContactValue;
//- (instancetype)initWithCNContact:(CNContact *)contact;
//- (instancetype)initWithline1:(nullable NSString *)line1
//                        line2:(nullable NSString *)line2
//                         city:(nullable NSString *)city
//                      country:(nullable NSString *)country
//                        state:(nullable NSString *)state
//                   postalCode:(nullable NSString *)postalCode;

//- (BOOL)containsRequiredFields:(SPBillingAddressFields)requiredFields;
//- (BOOL)containsContentForBillingAddressFields:
//(SPBillingAddressFields)desiredFields;
//- (BOOL)containsRequiredShippingAddressFields:
//(nullable NSSet<SPContactField> *)requiredFields;
//- (BOOL)containsContentForShippingAddressFields:
//(nullable NSSet<SPContactField> *)desiredFields;
//- (NSDictionary *_Nullable )dictionary;
@end

NS_ASSUME_NONNULL_END
