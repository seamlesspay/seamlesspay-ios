/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPTheme.h"
#import "SPColorUtils.h"

typedef UIColor * (^SPColorBlock)(void);

@interface SPTheme ()
@property(nonatomic) NSNumber *internalBarStyle;
@end

static UIColor *SPThemeDefaultPrimaryBackgroundColor;
static UIColor *SPThemeDefaultSecondaryBackgroundColor;
static UIColor *SPThemeDefaultPrimaryForegroundColor;
static UIColor *SPThemeDefaultSecondaryForegroundColor;
static UIColor *SPThemeDefaultAccentColor;
static UIColor *SPThemeDefaultErrorColor;
static UIFont *SPThemeDefaultFont;
static UIFont *SPThemeDefaultMediumFont;

@implementation SPTheme

+ (void)initialize {
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    SPThemeDefaultPrimaryBackgroundColor =
    [UIColor secondarySystemBackgroundColor];
    SPThemeDefaultSecondaryBackgroundColor = [UIColor systemBackgroundColor];
    SPThemeDefaultPrimaryForegroundColor = [UIColor labelColor];
    SPThemeDefaultSecondaryForegroundColor = [UIColor secondaryLabelColor];
    SPThemeDefaultAccentColor = [UIColor systemBlueColor];
    SPThemeDefaultErrorColor = [UIColor systemRedColor];
  } else {
#endif
    SPThemeDefaultPrimaryBackgroundColor = [UIColor colorWithRed:242.0f / 255.0f
                                                           green:242.0f / 255.0f
                                                            blue:245.0f / 255.0f
                                                           alpha:1];
    SPThemeDefaultSecondaryBackgroundColor = [UIColor whiteColor];
    SPThemeDefaultPrimaryForegroundColor = [UIColor colorWithRed:43.0f / 255.0f
                                                           green:43.0f / 255.0f
                                                            blue:45.0f / 255.0f
                                                           alpha:1];
    SPThemeDefaultSecondaryForegroundColor =
    [UIColor colorWithRed:142.0f / 255.0f
                    green:142.0f / 255.0f
                     blue:147.0f / 255.0f
                    alpha:1];
    SPThemeDefaultAccentColor = [UIColor colorWithRed:0
                                                green:122.0f / 255.0f
                                                 blue:1
                                                alpha:1];
    SPThemeDefaultErrorColor = [UIColor colorWithRed:1
                                               green:72.0f / 255.0f
                                                blue:68.0f / 255.0f
                                               alpha:1];
#ifdef __IPHONE_13_0
  }
#endif
  SPThemeDefaultFont = [UIFont systemFontOfSize:17];

  SPThemeDefaultMediumFont = [UIFont systemFontOfSize:17.0f weight:0.2f]
  ?: [UIFont boldSystemFontOfSize:17];
}

+ (SPTheme *)defaultTheme {
  static SPTheme *SPThemeDefaultTheme;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    SPThemeDefaultTheme = [self new];
  });
  return SPThemeDefaultTheme;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _primaryBackgroundColor = SPThemeDefaultPrimaryBackgroundColor;
    _secondaryBackgroundColor = SPThemeDefaultSecondaryBackgroundColor;
    _primaryForegroundColor = SPThemeDefaultPrimaryForegroundColor;
    _secondaryForegroundColor = SPThemeDefaultSecondaryForegroundColor;
    _accentColor = SPThemeDefaultAccentColor;
    _errorColor = SPThemeDefaultErrorColor;
    _font = SPThemeDefaultFont;
    _emphasisFont = SPThemeDefaultMediumFont;
    _translucentNavigationBar = YES;
  }
  return self;
}

- (UIColor *)primaryBackgroundColor {
  return _primaryBackgroundColor ?: SPThemeDefaultPrimaryBackgroundColor;
}

- (UIColor *)secondaryBackgroundColor {
  return _secondaryBackgroundColor ?: SPThemeDefaultSecondaryBackgroundColor;
}

- (UIColor *)tertiaryBackgroundColor {
  SPColorBlock colorBlock = ^{
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [self.primaryBackgroundColor getHue:&hue
                             saturation:&saturation
                             brightness:&brightness
                                  alpha:&alpha];
    return [UIColor colorWithHue:hue
                      saturation:saturation
                      brightness:(brightness - 0.09f)
                           alpha:alpha];
  };
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(
                                                                UITraitCollection *__unused _Nonnull traitCollection) {
                                                                  return colorBlock();
                                                                }];
  } else {
#endif
    return colorBlock();
#ifdef __IPHONE_13_0
  }
#endif
}

- (UIColor *)primaryForegroundColor {
  return _primaryForegroundColor ?: SPThemeDefaultPrimaryForegroundColor;
}

- (UIColor *)secondaryForegroundColor {
  return _secondaryForegroundColor ?: SPThemeDefaultSecondaryForegroundColor;
}

- (UIColor *)tertiaryForegroundColor {
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(
                                                                UITraitCollection *__unused _Nonnull traitCollection) {
                                                                  return [self.primaryForegroundColor colorWithAlphaComponent:0.25f];
                                                                }];
  } else {
#endif
    return [self.primaryForegroundColor colorWithAlphaComponent:0.25f];
#ifdef __IPHONE_13_0
  }
#endif
}

- (UIColor *)quaternaryBackgroundColor {
  SPColorBlock colorBlock = ^{
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [self.primaryBackgroundColor getHue:&hue
                             saturation:&saturation
                             brightness:&brightness
                                  alpha:&alpha];
    return [UIColor colorWithHue:hue
                      saturation:saturation
                      brightness:(brightness - 0.03f)
                           alpha:alpha];
  };
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(
                                                                UITraitCollection *__unused _Nonnull traitCollection) {
                                                                  return colorBlock();
                                                                }];
  } else {
#endif
    return colorBlock();
#ifdef __IPHONE_13_0
  }
#endif
}

- (UIColor *)accentColor {
  return _accentColor ?: SPThemeDefaultAccentColor;
}

- (UIColor *)errorColor {
  return _errorColor ?: SPThemeDefaultErrorColor;
}

- (UIFont *)font {
  return _font ?: SPThemeDefaultFont;
}

- (UIFont *)emphasisFont {
  return _emphasisFont ?: SPThemeDefaultMediumFont;
}

- (UIFont *)smallFont {
  return [self.font fontWithSize:self.font.pointSize - 2];
}

- (UIFont *)largeFont {
  return [self.font fontWithSize:self.font.pointSize + 15];
}

- (UIBarStyle)barStyleForColor:(UIColor *)color {
  if ([SPColorUtils colorIsBright:color]) {
    return UIBarStyleDefault;
  } else {
    return UIBarStyleBlack;
  }
}

- (void)setBarStyle:(UIBarStyle)barStyle {
  _internalBarStyle = @(barStyle);
}

- (UIBarStyle)barStyle {
  if (_internalBarStyle != nil) {
    return [_internalBarStyle integerValue];
  }
  return [self barStyleForColor:self.secondaryBackgroundColor];
}

- (id)copyWithZone:(__unused NSZone *)zone {
  SPTheme *copyTheme = [self.class new];
  copyTheme.primaryBackgroundColor = self.primaryBackgroundColor;
  copyTheme.secondaryBackgroundColor = self.secondaryBackgroundColor;
  copyTheme.primaryForegroundColor = self.primaryForegroundColor;
  copyTheme.secondaryForegroundColor = self.secondaryForegroundColor;
  copyTheme.accentColor = self.accentColor;
  copyTheme.errorColor = self.errorColor;
  copyTheme.font = self.font;
  copyTheme.emphasisFont = self.emphasisFont;
  copyTheme.translucentNavigationBar = self.translucentNavigationBar;
  return copyTheme;
}

@end
