//
//  SPPaymentCardTextFieldViewModel.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SPCard.h"
#import "SPCardValidator.h"
#import "SPPostalCodeValidator.h"

typedef NS_ENUM(NSInteger, SPCardFieldType) {
    SPCardFieldTypeNumber,
    SPCardFieldTypeExpiration,
    SPCardFieldTypeCVC,
    SPCardFieldTypePostalCode,
};

@interface SPPaymentCardTextFieldViewModel : NSObject

@property (nonatomic, readwrite, copy, nullable) NSString *cardNumber;
@property (nonatomic, readonly, nullable) NSString *compressedCardNumber;
@property (nonatomic, readwrite, copy, nullable) NSString *rawExpiration;
@property (nonatomic, readonly, nullable) NSString *expirationMonth;
@property (nonatomic, readonly, nullable) NSString *expirationYear;
@property (nonatomic, readwrite, copy, nullable) NSString *cvc;
@property (nonatomic, readwrite, assign) BOOL postalCodeRequired;
@property (nonatomic, readwrite, copy, nullable) NSString *postalCode;
@property (nonatomic, readwrite, copy, nullable) NSString *postalCodeCountryCode;
@property (nonatomic, readonly) SPCardBrand brand;
@property (nonatomic, readonly) BOOL isValid;

- (nonnull NSString *)defaultPlaceholder;

- (SPCardValidationState)validationStateForField:(SPCardFieldType)fieldType;

@end
