/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import "NSArray+Extras.h"
#import "NSString+Extras.h"
#import "SPCardValidator+Extras.h"
#import "SPFormTextField.h"
#import "SingleLineCardForm.h"
#import "CardFormViewModel.h"

@interface CardForm (Private)
@property(nonatomic, readwrite, weak) UIImageView *brandImageView;
@property(nonatomic, readwrite, weak) UIView *fieldsView;
@property(nonatomic, readwrite, weak) SPFormTextField *numberField;
@property(nonatomic, readwrite, weak) SPFormTextField *expirationField;
@property(nonatomic, readwrite, weak) SPFormTextField *cvcField;
@property(nonatomic, readwrite, weak) SPFormTextField *postalCodeField;
@property(nonatomic, readwrite, strong)CardFormViewModel *viewModel;
@property(nonatomic, strong) NSArray<SPFormTextField *> *allFields;

- (NSString *)defaultPostalFieldPlaceholderForCountryCode:(NSString *)countryCode;

@end

@interface SingleLineCardForm ()

@property(nonatomic, readwrite, strong) SPFormTextField *sizingField;
@property(nonatomic, readwrite, strong) UILabel *sizingLabel;

//@property(nonatomic, strong) CardLogoImageViewManager *cardLogoImageViewManager;

/**
 This is a number-wrapped SPCardFieldType (or nil) that layout uses
 to determine how it should move/animate its subviews so that the chosen
 text field is fully visible.
 */
@property(nonatomic, copy) NSNumber *focusedTextFieldForLayout;

/*
 Creating and measuring the size of attributed strings is expensive so
 cache the values here.
 */
@property(nonatomic, strong)NSMutableDictionary<NSString *, NSNumber *> *textToWidthCache;
@property(nonatomic, strong)NSMutableDictionary<NSString *, NSNumber *> *numberToWidthCache;

@end

NS_INLINE CGFloat sp_ceilCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
  return ceil(x);
#else
  return ceilf(x);
#endif
}

@implementation SingleLineCardForm

CGFloat const SingleLineCardFormDefaultPadding = 13;
CGFloat const SingleLineCardFormDefaultInsets = 13;
CGFloat const SingleLineCardFormMinimumPadding = 10;

#pragma mark initializers

- (void)commonInit {
  [super commonInit];

  self.expirationField.alpha = 0;
  self.cvcField.alpha = 0;
  self.postalCodeField.alpha = 0;

  _sizingField = [self buildSizingTextField];
  _sizingField.formDelegate = nil;
  _sizingLabel = [UILabel new];

  self.focusedTextFieldForLayout = nil;
}

- (void)clearSizingCache {
  self.textToWidthCache = [NSMutableDictionary new];
  self.numberToWidthCache = [NSMutableDictionary new];
}

- (void)setFont:(UIFont *)font {
  [super setFont:font];

  self.sizingField.font = [font copy];
  [self clearSizingCache];

  [self setNeedsLayout];
}

- (NSString *)cardNumber {
  return self.viewModel.cardNumber;
}

- (BOOL)postalCodeEntryDisplayed {
  return self.viewModel.postalCodeDisplayed;
}

- (BOOL)cvcEntryDisplayed {
  return self.viewModel.cvcDisplayed;
}


- (BOOL)resignFirstResponder {
  BOOL success = [super resignFirstResponder];

  [self layoutViewsToFocusField:nil
           becomeFirstResponder:NO
                       animated:YES
                     completion:nil];

  return success;
}

- (void)clear {
  [super clear];
  
  __weak typeof(self) weakSelf = self;
  [self layoutViewsToFocusField:@(SPCardFieldTypePostalCode)
           becomeFirstResponder:YES
                       animated:YES
                     completion:^(__unused BOOL completed) {
    __strong typeof(self) strongSelf = weakSelf;
    if ([strongSelf isFirstResponder]) {
      [[strongSelf numberField] becomeFirstResponder];
    }
  }];
}

- (CGFloat)numberFieldFullWidth {
  // Current longest possible pan is 16 digits which our standard sample fits
  if ([self.viewModel isFieldValid:SPCardFieldTypeNumber]) {
    return [self widthForCardNumber:self.viewModel.cardNumber];
  } else {
    return MAX([self widthForCardNumber:self.viewModel.cardNumber],
               [self widthForCardNumber:self.viewModel.defaultPlaceholder]);
  }
}

- (CGFloat)numberFieldCompressedWidth {

  NSString *cardNumber = self.cardNumber;
  if (cardNumber.length == 0) {
    cardNumber = self.viewModel.defaultPlaceholder;
  }

  SPCardBrand currentBrand = [SPCardValidator brandForNumber:cardNumber];
  NSArray<NSNumber *> *sortedCardNumberFormat =
  [[SPCardValidator cardNumberFormatForBrand:currentBrand]
   sortedArrayUsingSelector:@selector(unsignedIntegerValue)];
  NSUInteger fragmentLength =
  [SPCardValidator fragmentLengthForCardBrand:currentBrand];
  NSUInteger maxLength =
  MAX([[sortedCardNumberFormat lastObject] unsignedIntegerValue],
      fragmentLength);

  NSString *maxCompressedString = [@"" stringByPaddingToLength:maxLength
                                                    withString:@"8"
                                               startingAtIndex:0];
  return [self widthForText:maxCompressedString];
}

- (CGFloat)cvcFieldWidth {
  if (self.focusedTextFieldForLayout == nil && [self.viewModel isFieldValid:SPCardFieldTypeCVC]) {
    // If we're not focused and have valid text, size exactly to what is entered
    return [self widthForText:self.viewModel.cvc];
  } else {
    // Otherwise size to fit our placeholder or what is likely to be the
    // largest possible string enterable (whichever is larger)
    NSInteger maxCvcLength =
    [SPCardValidator maxCVCLengthForCardBrand:self.viewModel.brand];
    NSString *longestCvc = @"888";
    if (maxCvcLength == 4) {
      longestCvc = @"8888";
    }

    return MAX([self widthForText:self.cvcField.placeholder],
               [self widthForText:longestCvc]);
  }
}

- (CGFloat)expirationFieldWidth {
  if (self.focusedTextFieldForLayout == nil && [self.viewModel isFieldValid:SPCardFieldTypeExpiration]) {
    // If we're not focused and have valid text, size exactly to what is entered
    return [self widthForText:self.viewModel.rawExpiration];
  } else {
    // Otherwise size to fit our placeholder or what is likely to be the
    // largest possible string enterable (whichever is larger)
    return MAX([self widthForText:self.expirationField.placeholder],
               [self widthForText:@"88/88"]);
  }
}

- (CGFloat)postalCodeFieldFullWidth {
  CGFloat compressedWidth = [self postalCodeFieldCompressedWidth];
  CGFloat currentTextWidth = [self widthForText:self.viewModel.postalCode];

  if (currentTextWidth <= compressedWidth) {
    return compressedWidth;
  } else if ([self.countryCode.uppercaseString isEqualToString:@"US"]) {
    // This format matches ZIP+4 which is currently disabled since it is
    // not used for billing, but could be useful for future shipping addr
    // purposes
    return [self widthForText:@"88888-8888"];
  } else {
    // This format more closely matches the typical max UK/Canadian size which
    // is our most common non-US market currently
    return [self widthForText:@"888 8888"];
  }
}

- (CGFloat)postalCodeFieldCompressedWidth {
  CGFloat maxTextWidth = 0;
  if ([self.countryCode.uppercaseString isEqualToString:@"US"]) {
    maxTextWidth = [self widthForText:@"88888"];
  } else {
    // This format more closely matches the typical max UK/Canadian size which
    // is our most common non-US market currently
    maxTextWidth = [self widthForText:@"888 8888"];
  }

  CGFloat placeholderWidth = [self widthForText: [self defaultPostalFieldPlaceholderForCountryCode:self.countryCode]];
  return MAX(maxTextWidth, placeholderWidth);
}

- (CGSize)intrinsicContentSize {

  CGSize imageSize = self.brandImage.size;

  self.sizingField.text = self.viewModel.defaultPlaceholder;
  [self.sizingField sizeToFit];
  CGFloat textHeight = CGRectGetHeight(self.sizingField.frame);
  CGFloat imageHeight =
  imageSize.height + (SingleLineCardFormDefaultInsets);
  CGFloat height = sp_ceilCGFloat((MAX(MAX(imageHeight, textHeight), 44)));

  CGFloat width =
  (SingleLineCardFormDefaultInsets + imageSize.width +
   SingleLineCardFormDefaultInsets + [self numberFieldFullWidth] +
   SingleLineCardFormDefaultInsets);

  width = sp_ceilCGFloat(width);

  return CGSizeMake(width, height);
}

typedef NS_ENUM(NSInteger, SingleLineCardFormState) {
  SingleLineCardFormVisible,
  SingleLineCardFormCompressed,
  SingleLineCardFormHidden,
};

- (CGFloat)minimumPaddingForViewsWithWidth:(CGFloat)width
                                       pan:(SingleLineCardFormState)panVisibility
                                    expiry:(SingleLineCardFormState)expiryVisibility
                                       cvc:(SingleLineCardFormState)cvcVisibility
                                    postal:(SingleLineCardFormState)postalVisibility {

  CGFloat requiredWidth = 0;
  CGFloat paddingsRequired = -1;

  if (panVisibility != SingleLineCardFormHidden) {
    paddingsRequired += 1;
    requiredWidth += (panVisibility == SingleLineCardFormCompressed)
    ? [self numberFieldCompressedWidth]
    : [self numberFieldFullWidth];
  }

  if (expiryVisibility != SingleLineCardFormHidden) {
    paddingsRequired += 1;
    requiredWidth += [self expirationFieldWidth];
  }

  if (cvcVisibility != SingleLineCardFormHidden && self.cvcEntryDisplayed) {
    paddingsRequired += 1;
    requiredWidth += [self cvcFieldWidth];
  }

  if (postalVisibility != SingleLineCardFormHidden && self.postalCodeEntryDisplayed) {
    paddingsRequired += 1;
    requiredWidth += (postalVisibility == SingleLineCardFormCompressed)
    ? [self postalCodeFieldCompressedWidth]
    : [self postalCodeFieldFullWidth];
  }

  if (paddingsRequired > 0) {
    return sp_ceilCGFloat(((width - requiredWidth) / paddingsRequired));
  } else {
    return SingleLineCardFormMinimumPadding;
  }
}

- (CGRect)brandImageRectForBounds:(CGRect)bounds {
  return CGRectMake(SingleLineCardFormDefaultPadding, -1,
                    self.brandImageView.image.size.width, bounds.size.height);
}

- (CGRect)fieldsRectForBounds:(CGRect)bounds {
  CGRect brandImageRect = [self brandImageRectForBounds:bounds];
  return CGRectMake(CGRectGetMaxX(brandImageRect), 0,
                    CGRectGetWidth(bounds) - CGRectGetMaxX(brandImageRect),
                    CGRectGetHeight(bounds));
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self recalculateSubviewLayout];
}

- (void)recalculateSubviewLayout {

  CGRect bounds = self.bounds;

  self.brandImageView.frame = [self brandImageRectForBounds:bounds];
  CGRect fieldsViewRect = [self fieldsRectForBounds:bounds];
  self.fieldsView.frame = fieldsViewRect;

  CGFloat availableFieldsWidth = CGRectGetWidth(fieldsViewRect) -
  (2 * SingleLineCardFormDefaultInsets);

  // These values are filled in via the if statements and then used
  // to do the proper layout at the end
  CGFloat fieldsHeight = CGRectGetHeight(fieldsViewRect);
  CGFloat hPadding = SingleLineCardFormDefaultPadding;
  __block SingleLineCardFormState panVisibility = SingleLineCardFormVisible;
  __block SingleLineCardFormState expiryVisibility = SingleLineCardFormVisible;
  __block SingleLineCardFormState cvcVisibility =
  self.cvcEntryDisplayed ? SingleLineCardFormVisible : SingleLineCardFormHidden;
  __block SingleLineCardFormState postalVisibility =
  self.postalCodeEntryDisplayed ? SingleLineCardFormVisible : SingleLineCardFormHidden;

  CGFloat (^calculateMinimumPaddingWithLocalVars)(void) = ^CGFloat() {
    return [self minimumPaddingForViewsWithWidth:availableFieldsWidth
                                             pan:panVisibility
                                          expiry:expiryVisibility
                                             cvc:cvcVisibility
                                          postal:postalVisibility];
  };

  hPadding = calculateMinimumPaddingWithLocalVars();

  if (hPadding >= SingleLineCardFormMinimumPadding) {
    // Can just render everything at full size
    // Do Nothing
  } else {
    // Need to do selective view compression/hiding

    if (self.focusedTextFieldForLayout == nil) {
      /*
       No field is currently being edited -

       Render all fields visible:
       Show compressed PAN, visible CVC and expiry, fill remaining space
       with postal if necessary

       The most common way to be in this state is the user finished entry
       and has moved on to another field (so we want to show summary)
       but possibly some fields are invalid
       */
      while (hPadding < SingleLineCardFormMinimumPadding) {
        // Try hiding things in this order
        if (panVisibility ==   SingleLineCardFormVisible) {
          panVisibility = SingleLineCardFormCompressed;
        } else if (postalVisibility ==   SingleLineCardFormVisible) {
          postalVisibility = SingleLineCardFormCompressed;
        } else {
          // Can't hide anything else, set to minimum and stop
          hPadding = SingleLineCardFormMinimumPadding;
          break;
        }
        hPadding = calculateMinimumPaddingWithLocalVars();
      }
    } else {
      switch ((SPCardFieldType)self.focusedTextFieldForLayout.integerValue) {
        case SPCardFieldTypeNumber: {
          /*
           The user is entering PAN

           It must be fully visible. Everything else is optional
           */

          while (hPadding < SingleLineCardFormMinimumPadding) {
            if (postalVisibility ==   SingleLineCardFormVisible) {
              postalVisibility = SingleLineCardFormCompressed;
            } else if (postalVisibility == SingleLineCardFormCompressed) {
              postalVisibility = SingleLineCardFormHidden;
            } else if (cvcVisibility ==   SingleLineCardFormVisible) {
              cvcVisibility = SingleLineCardFormHidden;
            } else if (expiryVisibility ==   SingleLineCardFormVisible) {
              expiryVisibility = SingleLineCardFormHidden;
            } else {
              hPadding = SingleLineCardFormMinimumPadding;
              break;
            }
            hPadding = calculateMinimumPaddingWithLocalVars();
          }
        } break;
        case SPCardFieldTypeExpiration: {
          /*
           The user is entering expiration date

           It must be fully visible, and the next and previous fields
           must be visible so they can be tapped over to
           */
          while (hPadding < SingleLineCardFormMinimumPadding) {
            if (panVisibility ==   SingleLineCardFormVisible) {
              panVisibility = SingleLineCardFormCompressed;
            } else if (postalVisibility ==   SingleLineCardFormVisible) {
              postalVisibility = SingleLineCardFormCompressed;
            } else if (postalVisibility == SingleLineCardFormCompressed) {
              postalVisibility = SingleLineCardFormHidden;
            } else {
              hPadding = SingleLineCardFormMinimumPadding;
              break;
            }
            hPadding = calculateMinimumPaddingWithLocalVars();
          }
        } break;

        case SPCardFieldTypeCVC: {
          /*
           The user is entering CVC

           It must be fully visible, and the next and previous fields
           must be visible so they can be tapped over to (although
           there might not be a next field)
           */
          while (hPadding < SingleLineCardFormMinimumPadding) {
            if (panVisibility ==   SingleLineCardFormVisible) {
              panVisibility = SingleLineCardFormCompressed;
            } else if (postalVisibility ==   SingleLineCardFormVisible) {
              postalVisibility = SingleLineCardFormCompressed;
            } else if (panVisibility == SingleLineCardFormCompressed) {
              panVisibility = SingleLineCardFormHidden;
            } else {
              hPadding = SingleLineCardFormMinimumPadding;
              break;
            }
            hPadding = calculateMinimumPaddingWithLocalVars();
          }
        } break;
        case SPCardFieldTypePostalCode: {
          /*
           The user is entering postal code

           It must be fully visible, and the previous field must
           be visible
           */
          while (hPadding < SingleLineCardFormMinimumPadding) {
            if (panVisibility ==   SingleLineCardFormVisible) {
              panVisibility = SingleLineCardFormCompressed;
            } else if (panVisibility == SingleLineCardFormCompressed) {
              panVisibility = SingleLineCardFormHidden;
            } else if (expiryVisibility ==   SingleLineCardFormVisible) {
              expiryVisibility = SingleLineCardFormHidden;
            } else {
              hPadding = SingleLineCardFormMinimumPadding;
              break;
            }
            hPadding = calculateMinimumPaddingWithLocalVars();
          }
        } break;
      }
    }
  }

  // -- Do layout here --
  CGFloat xOffset = SingleLineCardFormDefaultInsets;
  CGFloat width = 0;

  // Make all fields actually slightly wider than needed so that when the
  // cursor is at the end position the contents aren't clipped off to the left
  // side
  CGFloat additionalWidth = [self widthForText:@"8"];

  if (panVisibility == SingleLineCardFormCompressed) {
    // Need to lower xOffset so pan is partially off-screen

    BOOL hasEnteredCardNumber = self.cardNumber.length > 0;
    NSString *compressedCardNumber = self.viewModel.compressedCardNumber;
    NSString *cardNumberToHide =
    [(hasEnteredCardNumber ? self.cardNumber : self.numberPlaceholder)
     sp_stringByRemovingSuffix:compressedCardNumber];

    if (cardNumberToHide.length > 0 &&
        [SPCardValidator stringIsNumeric:cardNumberToHide]) {
      width = hasEnteredCardNumber ? [self widthForCardNumber:self.cardNumber]
      : [self numberFieldFullWidth];

      CGFloat hiddenWidth = [self widthForCardNumber:cardNumberToHide];
      xOffset -= hiddenWidth;
      UIView *maskView = [[UIView alloc]
                          initWithFrame:CGRectMake(hiddenWidth, 0, (width - hiddenWidth),
                                                   fieldsHeight)];
      maskView.backgroundColor = [UIColor blackColor];
#ifdef __IPHONE_13_0
      if (@available(iOS 13.0, *)) {
        maskView.backgroundColor = [UIColor labelColor];
      }
#endif
      maskView.opaque = YES;
      maskView.userInteractionEnabled = NO;
      [UIView performWithoutAnimation:^{
        self.numberField.maskView = maskView;
      }];
    } else {
      width = [self numberFieldCompressedWidth];
      [UIView performWithoutAnimation:^{
        self.numberField.maskView = nil;
      }];
    }
  } else {
    width = [self numberFieldFullWidth];
    [UIView performWithoutAnimation:^{
      self.numberField.maskView = nil;
    }];

    if (panVisibility == SingleLineCardFormHidden) {
      // Need to lower xOffset so pan is fully off screen
      xOffset = xOffset - width - hPadding;
    }
  }

  self.numberField.frame =
  CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
  xOffset += width + hPadding;

  width = [self expirationFieldWidth];
  self.expirationField.frame =
  CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
  xOffset += width + hPadding;

  if (self.cvcEntryDisplayed) {
    width = [self cvcFieldWidth];
    self.cvcField.frame =
    CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
    xOffset += width + hPadding;
  }

  if (self.postalCodeEntryDisplayed) {
    width = self.fieldsView.frame.size.width - xOffset -
    SingleLineCardFormDefaultInsets;
    self.postalCodeField.frame =
    CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
  }

  void (^updateFieldVisibility)(SPFormTextField *, SingleLineCardFormState) =
  ^(SPFormTextField *field, SingleLineCardFormState fieldState) {
    if (fieldState == SingleLineCardFormHidden) {
      field.alpha = 0.0f;
      field.isAccessibilityElement = NO;
    } else {
      field.alpha = 1.0f;
      field.isAccessibilityElement = YES;
    }
  };

  updateFieldVisibility(self.numberField, panVisibility);
  updateFieldVisibility(self.expirationField, expiryVisibility);
  updateFieldVisibility(self.cvcField, self.cvcEntryDisplayed
                        ? cvcVisibility
                        : SingleLineCardFormHidden);
  updateFieldVisibility(self.postalCodeField, self.postalCodeEntryDisplayed
                        ? postalVisibility
                        : SingleLineCardFormHidden);
}

#pragma mark - private helper methods

- (SPFormTextField *)buildSizingTextField {
  SPFormTextField *textField = [[SPFormTextField alloc] initWithFrame:CGRectZero];
  textField.backgroundColor = [UIColor clearColor];
  // setCountryCode: updates the postalCodeField keyboardType, this is safe
  textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
  textField.textAlignment = NSTextAlignmentLeft;
  textField.font = self.font;
  textField.defaultColor = self.textColor;
  textField.errorColor = self.textErrorColor;
  textField.placeholderColor = self.placeholderColor;
  textField.formDelegate = nil;
  textField.validText = true;
  return textField;
}

typedef void (^SPLayoutAnimationCompletionBlock)(BOOL completed);
- (void)layoutViewsToFocusField:(NSNumber *)focusedField
           becomeFirstResponder:(BOOL)shouldBecomeFirstResponder
                       animated:(BOOL)animated
                     completion:(SPLayoutAnimationCompletionBlock)completion {

  NSNumber *fieldtoFocus = focusedField;

  if (fieldtoFocus == nil &&
      ![self.focusedTextFieldForLayout
        isEqualToNumber:@(SPCardFieldTypeNumber)] &&
      ([self.viewModel validationStateForField:SPCardFieldTypeNumber] !=
       SPCardValidationStateValid)) {
    fieldtoFocus = @(SPCardFieldTypeNumber);
    if (shouldBecomeFirstResponder) {
      [self.numberField becomeFirstResponder];
    }
  }

  if ((fieldtoFocus == nil && self.focusedTextFieldForLayout == nil) ||
      (fieldtoFocus != nil &&
       [self.focusedTextFieldForLayout isEqualToNumber:fieldtoFocus])) {
    if (completion) {
      completion(YES);
    }
    return;
  }

  self.focusedTextFieldForLayout = fieldtoFocus;

  void (^animations)(void) = ^void() {
    [self recalculateSubviewLayout];
  };

  if (animated) {
    NSTimeInterval duration = animated * 0.3;
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.85f
          initialSpringVelocity:0
                        options:0
                     animations:animations
                     completion:completion];
  } else {
    animations();
  }
}

- (CGFloat)widthForAttributedText:(NSAttributedString *)attributedText {
  // UITextField doesn't seem to size correctly here for unknown reasons
  // But UILabel reliably calculates size correctly using this method
  self.sizingLabel.attributedText = attributedText;
  [self.sizingLabel sizeToFit];
  return sp_ceilCGFloat((CGRectGetWidth(self.sizingLabel.bounds)));
}

- (CGFloat)widthForText:(NSString *)text {
  if (text.length == 0) {
    return 0;
  }

  NSNumber *cachedValue = self.textToWidthCache[text];
  if (cachedValue == nil) {
    self.sizingField.autoFormattingBehavior =
    SPFormTextFieldAutoFormattingBehaviorNone;
    [self.sizingField setText:text];
    cachedValue =
    @([self widthForAttributedText:self.sizingField.attributedText]);
    self.textToWidthCache[text] = cachedValue;
  }
  return (CGFloat)[cachedValue doubleValue];
}

- (CGFloat)widthForCardNumber:(NSString *)cardNumber {
  if (cardNumber.length == 0) {
    return 0;
  }

  NSNumber *cachedValue = self.numberToWidthCache[cardNumber];
  if (cachedValue == nil) {
    self.sizingField.autoFormattingBehavior =
    SPFormTextFieldAutoFormattingBehaviorCardNumbers;
    [self.sizingField setText:cardNumber];
    cachedValue =
    @([self widthForAttributedText:self.sizingField.attributedText]);
    self.numberToWidthCache[cardNumber] = cachedValue;
  }
  return (CGFloat)[cachedValue doubleValue];
}

@end
