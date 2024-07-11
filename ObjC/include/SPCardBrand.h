/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

/**
 The various card brands to which a payment card can belong.
 */
typedef NS_ENUM(NSInteger, SPCardBrand) {

  /**
   Visa card
   */
  SPCardBrandVisa,

  /**
   American Express card
   */
  SPCardBrandAmex,

  /**
   Mastercard card
   */
  SPCardBrandMasterCard,

  /**
   Discover card
   */
  SPCardBrandDiscover,

  /**
   JCB card
   */
  SPCardBrandJCB,

  /**
   Diners Club card
   */
  SPCardBrandDinersClub,

  /**
   UnionPay card
   */
  SPCardBrandUnionPay,

  /**
   An unknown card brand type
   */
  SPCardBrandUnknown,
};
