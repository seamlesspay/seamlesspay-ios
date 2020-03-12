/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPValidatedTextField.h"

@implementation SPValidatedTextField

#pragma mark - Property Overrides

- (void)setDefaultColor:(UIColor *)defaultColor {
  _defaultColor = defaultColor;
  [self updateColor];
}

- (void)setErrorColor:(UIColor *)errorColor {
  _errorColor = errorColor;
  [self updateColor];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
  _placeholderColor = placeholderColor;
  // explicitly rebuild attributed placeholder to pick up new color
  [self setPlaceholder:self.placeholder];
}

- (void)setValidText:(BOOL)validText {
  _validText = validText;
  [self updateColor];
}

#pragma mark - UITextField overrides

- (void)setPlaceholder:(NSString *)placeholder {
  NSString *nonNilPlaceholder = placeholder ?: @"";
  NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:nonNilPlaceholder
          attributes:[self placeholderTextAttributes]];
  [self setAttributedPlaceholder:attributedPlaceholder];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

#pragma mark - Private Methods

- (void)updateColor {
  self.textColor = _validText ? self.defaultColor : self.errorColor;
}

- (NSDictionary *)placeholderTextAttributes {
  NSMutableDictionary *defaultAttributes =
      [[self defaultTextAttributes] mutableCopy];
  if (self.placeholderColor) {
    defaultAttributes[NSForegroundColorAttributeName] = self.placeholderColor;
  }
  return [defaultAttributes copy];
}

@end
