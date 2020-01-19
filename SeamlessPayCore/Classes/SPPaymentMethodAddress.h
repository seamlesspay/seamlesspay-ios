/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "SPFormEncodable.h"

NS_ASSUME_NONNULL_BEGIN

@class SPAddress;

/**
 The billing address, a property on `SPPaymentMethodBillingDetails`
 */
@interface SPPaymentMethodAddress : NSObject <SPFormEncodable>

/**
 City/District/Suburb/Town/Village.
*/
@property(nonatomic, copy, nullable, readwrite) NSString *city;

/**
 2-letter country code.
 */
@property(nonatomic, copy, nullable, readwrite) NSString *country;

/**
 Address line 1 (Street address/PO Box/Company name).
 */
@property(nonatomic, copy, nullable, readwrite) NSString *line1;

/**
 Address line 2 (Apartment/Suite/Unit/Building).
 */
@property(nonatomic, copy, nullable, readwrite) NSString *line2;

/**
 ZIP or postal code.
 */
@property(nonatomic, copy, nullable, readwrite) NSString *postalCode;

/**
 State/County/Province/Region.
 */
@property(nonatomic, copy, nullable, readwrite) NSString *state;

/**
 Convenience initializer for creating a SPPaymentMethodAddress from an
 SPAddress.
 */
- (instancetype)initWithAddress:(SPAddress *)address;

@end

NS_ASSUME_NONNULL_END
