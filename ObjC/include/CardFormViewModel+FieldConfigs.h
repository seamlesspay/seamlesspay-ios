/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import "CardFormViewModel.h"

@interface CardFormViewModel (FieldConfigs)

// Properties for CVC field configuration
@property(nonatomic, readonly, assign) BOOL cvcDisplayed;
@property(nonatomic, readonly, assign) BOOL cvcRequired;

// Properties for Postal Code field configuration
@property(nonatomic, readonly, assign) BOOL postalCodeDisplayed;
@property(nonatomic, readonly, assign) BOOL postalCodeRequired;

@end
