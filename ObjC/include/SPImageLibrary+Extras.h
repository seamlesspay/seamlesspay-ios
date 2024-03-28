/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPImageLibrary.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPImageLibrary (Extras)

+ (UIImage *)addIcon;
+ (UIImage *)bankIcon;
+ (UIImage *)checkmarkIcon;
+ (UIImage *)largeCardFrontImage;
+ (UIImage *)largeCardBackImage;
+ (UIImage *)largeCardAmexCVCImage;
+ (UIImage *)largeShippingImage;
+ (UIImage *)safeImageNamed:(NSString *)imageName
        templateIfAvailable:(BOOL)templateIfAvailable;
+ (UIImage *)brandImageForCardBrand:(SPCardBrand)brand
                           template:(BOOL)isTemplate;
+ (UIImage *)imageWithTintColor:(UIColor *)color forImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
