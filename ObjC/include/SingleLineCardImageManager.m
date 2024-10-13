// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SingleLineCardImageManager.h"
#import "SPImageLibrary.h"

@interface SingleLineCardImageManager ()

@property (nonatomic, assign) SPCardFieldType currentFieldType;
@property (nonatomic, assign) SPCardBrand currentBrand;

@end

@implementation SingleLineCardImageManager

- (UIImage *)brandImageForFieldType:(SPCardFieldType)fieldType
                              brand:(SPCardBrand)brand
                         validation:(SPCardValidationState)validation {
    switch (fieldType) {
        case SPCardFieldTypeNumber:
            return (validation == SPCardValidationStateInvalid)
                ? [SPImageLibrary errorImageForCardBrand:brand]
                : [SPImageLibrary brandImageForCardBrand:brand];
        case SPCardFieldTypeCVC:
            return [SPImageLibrary cvcImageForCardBrand:brand];
        case SPCardFieldTypeExpiration:
        case SPCardFieldTypePostalCode:
            return [SPImageLibrary brandImageForCardBrand:brand];
    }
}

- (void)updateImageView:(UIImageView *)imageView
              fieldType:(SPCardFieldType)fieldType
                  brand:(SPCardBrand)brand
             validation:(SPCardValidationState)validation {

  UIImage *image = [self brandImageForFieldType:fieldType brand:brand validation:validation];

  if (![imageView.image isEqual:image]) {
    UIViewAnimationOptions animationOptions = [self transitionAnimationOptionsForNewType:fieldType
                                                                                 oldType:self.currentFieldType
                                                                                oldBrand:self.currentBrand
                                                                                newBrand:brand];

    self.currentFieldType = fieldType;
    self.currentBrand = brand;

    [UIView transitionWithView:imageView
                      duration:0.2
                       options:animationOptions
                    animations:^{ imageView.image = image; }
                    completion:nil];
  }
}

- (UIViewAnimationOptions)transitionAnimationOptionsForNewType:(SPCardFieldType)newType
                                                       oldType:(SPCardFieldType)oldType
                                                      oldBrand:(SPCardBrand)oldBrand
                                                      newBrand:(SPCardBrand)newBrand {

  if (newType == SPCardFieldTypeCVC && oldType != SPCardFieldTypeCVC) {
    // Transitioning to show CVC

    if (newBrand != SPCardBrandAmex) {
      // CVC is on the back
      return (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionFlipFromRight);
    }
  } else if (newType != SPCardFieldTypeCVC && oldType == SPCardFieldTypeCVC) {
    // Transitioning to stop showing CVC

    if (oldBrand != SPCardBrandAmex) {
      // CVC was on the back
      return (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionFlipFromLeft);
    }
  }

  // All other cases just cross dissolve
  return (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve);
}

@end
