//
//  SPImageLibrary+Extras.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

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
+ (UIImage *)imageWithTintColor:(UIColor *)color
                       forImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
