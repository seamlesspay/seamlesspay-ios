// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

#import <UIKit/UIKit.h>
#import "CardFormViewModel.h"

@protocol CardImageProvider <NSObject>

- (UIImage *)brandImageForFieldType:(SPCardFieldType)fieldType 
                              brand:(SPCardBrand)brand
                         validation:(SPCardValidationState)validation;

@end


@protocol CardImageManager <CardImageProvider>

- (void)updateImageView:(UIImageView *)imageView 
              fieldType:(SPCardFieldType)fieldType
                  brand:(SPCardBrand)brand
             validation:(SPCardValidationState)validation;

@end

@interface DefaultCardImageProvider : NSObject <CardImageProvider>
@end

@interface BaseCardImageManager : NSObject <CardImageManager>

- (void)updateImageView:(UIImageView *)imageView
              withImage:(UIImage *)image
       withAnimationOptions:(UIViewAnimationOptions) animationOptions;

@end

@interface SingleLineCardImageManager : BaseCardImageManager
@end
