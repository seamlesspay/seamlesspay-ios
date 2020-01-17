//
//  SPColorUtils.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <UIKit/UIKit.h>

@interface SPColorUtils : NSObject

+ (CGFloat)perceivedBrightnessForColor:(UIColor *)color;

+ (UIColor *)brighterColor:(UIColor *)color1 color2:(UIColor *)color2;

+ (BOOL)colorIsBright:(UIColor *)color;

@end
