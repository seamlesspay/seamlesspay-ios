// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

#import <UIKit/UIKit.h>
#import "CardFormViewModel.h"

@interface CardLogoImageViewManager : NSObject

- (instancetype)initWithViewModel:(id)viewModel;
- (void)updateImageView:(UIImageView *)brandImageView
          fieldType:(SPCardFieldType)fieldType
              brand:(SPCardBrand)brand
         validation:(SPCardValidationState) validationState;

@end

