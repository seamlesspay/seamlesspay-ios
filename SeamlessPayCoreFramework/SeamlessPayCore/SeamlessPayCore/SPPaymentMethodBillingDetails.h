//
//  SPPaymentMethodBillingDetails.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>


#import "SPFormEncodable.h"

@class SPPaymentMethodAddress;

NS_ASSUME_NONNULL_BEGIN

/**
 Billing information associated with a `SPPaymentMethod` that may be used or required by particular types of payment methods.
 */
@interface SPPaymentMethodBillingDetails : NSObject <SPFormEncodable>

/**
 Billing address.
 */
@property (nonatomic, strong, nullable) SPPaymentMethodAddress *address;

/**
 Email address.
 */
@property (nonatomic, copy, nullable) NSString *email;

/**
 Full name.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 Billing phone number (including extension).
 */
@property (nonatomic, copy, nullable) NSString *phone;

@end

NS_ASSUME_NONNULL_END
