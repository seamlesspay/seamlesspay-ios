//
//  SPColorUtils.h
//

#import <UIKit/UIKit.h>

@interface SPColorUtils : NSObject

+ (CGFloat)perceivedBrightnessForColor:(UIColor *)color;

+ (UIColor *)brighterColor:(UIColor *)color1 color2:(UIColor *)color2;

+ (BOOL)colorIsBright:(UIColor *)color;

@end
