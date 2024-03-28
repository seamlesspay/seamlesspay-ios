/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPColorUtils.h"

@implementation SPColorUtils

+ (CGFloat)perceivedBrightnessForColor:(UIColor *)color {
  CGFloat red, green, blue;
  if ([color getRed:&red green:&green blue:&blue alpha:nil]) {
    return red * (CGFloat)0.299 + green * (CGFloat)0.587 +
    blue * (CGFloat)0.114;
  } else {
    return (CGFloat)0.4;
  }
}

+ (UIColor *)brighterColor:(UIColor *)color1 color2:(UIColor *)color2 {
  CGFloat brightness1 = [self perceivedBrightnessForColor:color1];
  CGFloat brightness2 = [self perceivedBrightnessForColor:color2];
  return brightness1 >= brightness2 ? color1 : color2;
}

+ (BOOL)colorIsBright:(UIColor *)color {
  return [self perceivedBrightnessForColor:color] > 0.3;
}

@end
