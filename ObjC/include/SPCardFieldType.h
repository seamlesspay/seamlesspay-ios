/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SPCardFieldType) {
  SPCardFieldTypeNumber,
  SPCardFieldTypeExpiration,
  SPCardFieldTypeCVC,
  SPCardFieldTypePostalCode,
};
