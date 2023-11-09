/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardBrand.h"

NSString *SPStringFromCardBrand(SPCardBrand brand) {
  switch (brand) {
    case SPCardBrandAmex:
      return @"American Express";
    case SPCardBrandDinersClub:
      return @"Diners Club";
    case SPCardBrandDiscover:
      return @"Discover";
    case SPCardBrandJCB:
      return @"JCB";
    case SPCardBrandMasterCard:
      return @"Mastercard";
    case SPCardBrandUnionPay:
      return @"UnionPay";
    case SPCardBrandVisa:
      return @"Visa";
    case SPCardBrandUnknown:
      return @"Unknown";
  }
}
