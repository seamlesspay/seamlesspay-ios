//
//  SPPaymentMethodCardParams.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

#import "SPFormEncodable.h"

@class SPCardParams;

NS_ASSUME_NONNULL_BEGIN

/**
 The user's card details.
 */
@interface SPPaymentMethodCardParams : NSObject <SPFormEncodable>

/**
 A convenience initializer for creating a payment method from a card source.
 This should be used to help with migrations to Payment Methods from Sources.
 */
- (instancetype)initWithCardSourceParams:(SPCardParams *)cardSourceParams;

/**
 The card number, as a string without any separators. Ex. @"4242424242424242"
 */
@property (nonatomic, copy, nullable) NSString *number;

/**
 Number representing the card's expiration month. Ex. @1
 */
@property (nonatomic, nullable) NSNumber *expMonth;

/**
 Two- or four-digit number representing the card's expiration year.
 */
@property (nonatomic, nullable) NSNumber *expYear;

/**
 Token
 */
@property (nonatomic, copy, nullable) NSString *token;

/**
 Card security code. It is highly recommended to always include this value.
 */
@property (nonatomic, copy, nullable) NSString *cvc;

/**
The last 4 digits of the card.
*/
@property (nonatomic, readonly, nullable) NSString *last4;

@end

NS_ASSUME_NONNULL_END
