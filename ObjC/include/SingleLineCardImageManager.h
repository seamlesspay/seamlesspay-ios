// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

#import <UIKit/UIKit.h>
#import "CardFormViewModel.h"

@interface SingleLineCardImageManager : NSObject
- (void)updateImageView:(UIImageView *)imageView
              fieldType:(SPCardFieldType)fieldType
                  brand:(SPCardBrand)brand
             validation:(SPCardValidationState)validation;
@end
