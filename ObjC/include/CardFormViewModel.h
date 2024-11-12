/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SPCardValidator.h"
#import "SPCardFieldType.h"
#import "DisplayConfiguration.h"

@interface CardFormViewModel : NSObject

@property(nonatomic, readwrite, copy, nullable) NSString *cardNumber;
@property(nonatomic, readonly, nullable) NSString *compressedCardNumber;
@property(nonatomic, readwrite, copy, nullable) NSString *rawExpiration;
@property(nonatomic, readonly, nullable) NSString *expirationMonth;
@property(nonatomic, readonly, nullable) NSString *expirationYear;
@property(nonatomic, readwrite, copy, nullable) NSString *cvc;
@property(nonatomic, readwrite, copy, nullable) NSString *postalCode;
@property(nonatomic, readonly) SPCardBrand brand;
@property(nonatomic, readonly) BOOL isValid;

@property(nonatomic, assign) DisplayConfiguration cvcDisplayConfig;
@property(nonatomic, assign) DisplayConfiguration postalCodeDisplayConfig;


- (nonnull NSString *)defaultPlaceholder;
- (SPCardValidationState)validationStateForField:(SPCardFieldType)fieldType;
- (BOOL)isFieldValid:(SPCardFieldType)fieldType;

@end
