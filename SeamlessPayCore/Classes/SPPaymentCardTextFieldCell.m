/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPPaymentCardTextFieldCell.h"
#import "SPPaymentCardTextField+Extras.h"

@interface SPPaymentCardTextFieldCell ()

@property(nonatomic, weak) SPPaymentCardTextField *paymentField;

@end

@implementation SPPaymentCardTextFieldCell

- (instancetype)init {
  self = [super init];
  if (self) {
    SPPaymentCardTextField *paymentField =
    [[SPPaymentCardTextField alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:paymentField];
    _paymentField = paymentField;

    _theme = [SPTheme defaultTheme];
    [self updateAppearance];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.paymentField.frame = self.contentView.bounds;
}

- (void)setTheme:(SPTheme *)theme {
  _theme = theme;
  [self updateAppearance];
}

- (void)updateAppearance {
  self.paymentField.backgroundColor = [UIColor clearColor];
  self.paymentField.placeholderColor = self.theme.tertiaryForegroundColor;
  self.paymentField.borderColor = [UIColor clearColor];
  self.paymentField.textColor = self.theme.primaryForegroundColor;
  self.paymentField.textErrorColor = self.theme.errorColor;
  self.paymentField.font = self.theme.font;
  self.backgroundColor = self.theme.secondaryBackgroundColor;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
  _inputAccessoryView = inputAccessoryView;
  self.paymentField.inputAccessoryView = inputAccessoryView;
}

- (BOOL)isEmpty {
  return self.paymentField.cardNumber.length == 0;
}

- (BOOL)becomeFirstResponder {
  return [self.paymentField becomeFirstResponder];
}

- (NSInteger)accessibilityElementCount {
  return [[self.paymentField allFields] count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
  return [self.paymentField allFields][index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
  NSArray *fields = [self.paymentField allFields];
  for (NSUInteger i = 0; i < [fields count]; i++) {
    if (element == fields[i]) {
      return i;
    }
  }
  return 0;
}

@end
