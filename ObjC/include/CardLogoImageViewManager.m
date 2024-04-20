// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CardLogoImageViewManager.h"
#import "CardFormViewModel.h"
#import "SPImageLibrary.h"

@implementation CardLogoImageViewManager {
  /*
   These track the input parameters to the brand image setter so that we can
   later perform proper transition animations when new values are set
   */
  SPCardFieldType _currentBrandImageFieldType;
  SPCardBrand _currentBrandImageBrand;
}

// MARK: Init
- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

// MARK: Interface
- (void)updateImageView:(UIImageView *)brandImageView
          fieldType:(SPCardFieldType)fieldType
              brand:(SPCardBrand)brand
         validation:(SPCardValidationState) validationState {
  UIImage *image = [self brandImageForFieldType:fieldType brand:brand validation:validationState];

  if (![image isEqual:brandImageView.image]) {

    UIViewAnimationOptions imageAnimationOptions =
    [self brandImageAnimationOptionsForNewType:fieldType
                                      newBrand:brand
                                       oldType:_currentBrandImageFieldType
                                      oldBrand:_currentBrandImageBrand];

    _currentBrandImageFieldType = fieldType;
    _currentBrandImageBrand = brand;

    [UIView transitionWithView:brandImageView
                      duration:0.2
                       options:imageAnimationOptions
                    animations:^{ brandImageView.image = image; }
                    completion:nil];
  }
}

// MARK: Private
- (UIViewAnimationOptions)brandImageAnimationOptionsForNewType:(SPCardFieldType)newType
                                                      newBrand:(SPCardBrand)newBrand
                                                       oldType:(SPCardFieldType)oldType
                                                      oldBrand:(SPCardBrand)oldBrand {

  if (newType == SPCardFieldTypeCVC && oldType != SPCardFieldTypeCVC) {
    // Transitioning to show CVC

    if (newBrand != SPCardBrandAmex) {
      // CVC is on the back
      return (UIViewAnimationOptionCurveEaseInOut |
              UIViewAnimationOptionTransitionFlipFromRight);
    }
  } else if (newType != SPCardFieldTypeCVC && oldType == SPCardFieldTypeCVC) {
    // Transitioning to stop showing CVC

    if (oldBrand != SPCardBrandAmex) {
      // CVC was on the back
      return (UIViewAnimationOptionCurveEaseInOut |
              UIViewAnimationOptionTransitionFlipFromLeft);
    }
  }

  // All other cases just cross dissolve
  return (UIViewAnimationOptionCurveEaseInOut |
          UIViewAnimationOptionTransitionCrossDissolve);
}

- (UIImage *)brandImageForFieldType:(SPCardFieldType)fieldType
                              brand:(SPCardBrand)brand
                         validation:(SPCardValidationState) validationState {
  switch (fieldType) {
    case SPCardFieldTypeNumber:
      if (validationState == SPCardValidationStateInvalid) {
        return [SPImageLibrary errorImageForCardBrand:brand];
      } else {
        return [SPImageLibrary brandImageForCardBrand:brand];
      }
    case SPCardFieldTypeCVC:
      return [SPImageLibrary cvcImageForCardBrand:brand];
    case SPCardFieldTypeExpiration:
      return [SPImageLibrary brandImageForCardBrand:brand];
    case SPCardFieldTypePostalCode:
      return [SPImageLibrary brandImageForCardBrand:brand];
  }
}

@end
