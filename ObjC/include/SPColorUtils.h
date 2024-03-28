/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@interface SPColorUtils : NSObject

+ (CGFloat)perceivedBrightnessForColor:(UIColor *)color;
+ (UIColor *)brighterColor:(UIColor *)color1 color2:(UIColor *)color2;
+ (BOOL)colorIsBright:(UIColor *)color;

@end
