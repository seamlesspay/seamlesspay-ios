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
#import "CardFromImageManager.h"
#import "SPCardFormFieldEditingTransitionManager.h"

@interface SingleLineCardForm ()

@property(nonatomic, readwrite, strong) UIImageView *brandImageView;
@property(nonatomic, readwrite, strong) UIView *fieldsView;
@property(nonatomic, readwrite, strong) UIView *boundedView;
@property(nonatomic, readwrite, weak) SPFormTextField *numberField;
@property(nonatomic, readwrite, weak) SPFormTextField *expirationField;
@property(nonatomic, readwrite, weak) SPFormTextField *cvcField;
@property(nonatomic, readwrite, weak) SPFormTextField *postalCodeField;
@property(nonatomic, readwrite, strong)CardFormViewModel *viewModel;
@property(nonatomic, strong) NSArray<SPFormTextField *> *allFields;
@property(nonatomic, readonly, null_resettable) UIFont *font;
@property(nonatomic, readonly, null_resettable) UIColor *textColor;
@property(nonatomic, readonly, null_resettable) UIColor *textErrorColor;
@property(nonatomic, readonly, null_resettable) UIColor *placeholderColor;
@property(nonatomic, readonly, nullable) NSString *numberPlaceholder;
@property(nonatomic, readonly, nullable) NSString *expirationPlaceholder;
@property(nonatomic, readonly, nullable) NSString *cvcPlaceholder;
@property(nonatomic, readonly, nullable) NSString *postalCodePlaceholder;
@property(nonatomic, readwrite, strong) SPFormTextField *sizingField;
@property(nonatomic, readwrite, strong) UILabel *sizingLabel;

@property(nonatomic, strong) SingleLineCardImageManager *imageManager;
@property(nonatomic, strong) SPCardFormFieldEditingTransitionManager *fieldEditingTransitionManager;

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

@dynamic enabled;

CGFloat const SingleLineCardFormDefaultPadding = 13;
CGFloat const SingleLineCardFormDefaultInsets = 13;
CGFloat const SingleLineCardFormMinimumPadding = 10;
CGFloat const SingleLineCardFormBoundsMaximumHeight = 44;

#pragma mark Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self singleLineCardFormCommonInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self singleLineCardFormCommonInit];
  }
  return self;
}

- (void)singleLineCardFormCommonInit {

  self.clipsToBounds = YES;

  _viewModel = [CardFormViewModel new];

  UIImageView *brandImageView = [[UIImageView alloc] initWithImage:nil];
  brandImageView.contentMode = UIViewContentModeCenter;
  brandImageView.backgroundColor = [UIColor clearColor];
  brandImageView.tintColor = self.placeholderColor;
  self.brandImageView = brandImageView;
  [self updateImageForFieldType:SPCardFieldTypeNumber];

  SPFormTextField *numberField = [self buildTextField];
  // This does not offer quick-type suggestions (as iOS 11.2), but does pick
  // the best keyboard (maybe other, hidden behavior?)
  numberField.textContentType = UITextContentTypeCreditCardNumber;
  numberField.autoFormattingBehavior =
  SPFormTextFieldAutoFormattingBehaviorCardNumbers;
  numberField.tag = SPCardFieldTypeNumber;
  numberField.accessibilityLabel = @"card number";
  self.numberField = numberField;
  self.numberPlaceholder = [self.viewModel defaultPlaceholder];

  SPFormTextField *expirationField = [self buildTextField];
  expirationField.autoFormattingBehavior =
  SPFormTextFieldAutoFormattingBehaviorExpiration;
  expirationField.tag = SPCardFieldTypeExpiration;
  expirationField.isAccessibilityElement = NO;
  expirationField.accessibilityLabel = @"expiration date";
  self.expirationField = expirationField;
  self.expirationPlaceholder = @"MM/YY";

  SPFormTextField *cvcField = [self buildTextField];
  cvcField.tag = SPCardFieldTypeCVC;
  cvcField.isAccessibilityElement = NO;
  self.cvcField = cvcField;
  self.cvcPlaceholder = nil;
  self.cvcField.accessibilityLabel = [self defaultCVCPlaceholder];

  SPFormTextField *postalCodeField = [self buildTextField];
  postalCodeField.textContentType = UITextContentTypePostalCode;
  postalCodeField.tag = SPCardFieldTypePostalCode;
  postalCodeField.isAccessibilityElement = NO;
  self.postalCodeField = postalCodeField;
  // Placeholder and appropriate keyboard typeare set by country code setter

  UIView *boundedView = [[UIView alloc] init];
  boundedView.clipsToBounds = YES;
  boundedView.backgroundColor = [UIColor whiteColor];
  boundedView.layer.borderColor = [[self.placeholderColor copy] CGColor];
  boundedView.layer.cornerRadius = 5.0f;
  boundedView.layer.borderWidth = 1.0f;
  self.boundedView = boundedView;

  UIView *fieldsView = [[UIView alloc] init];
  fieldsView.clipsToBounds = YES;
  fieldsView.backgroundColor = [UIColor clearColor];
  self.fieldsView = fieldsView;

  self.allFields = @[ numberField, expirationField, cvcField, postalCodeField ];

  // On small screens, the number field fits ~4 numbers, and the brandImage is
  // just as large. Previously, taps on the brand image would *dismiss* the
  // keyboard. Make it move to the numberField instead
  brandImageView.userInteractionEnabled = YES;
  [brandImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:numberField
                                        action:@selector(becomeFirstResponder)]];

  [self updateCVCPlaceholder];
  [self.fieldEditingTransitionManager resetSubviewEditingTransitionState];
  self.countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];

  [self addSubview:self.boundedView];

  [self.boundedView addSubview:self.fieldsView];

  for (SPFormTextField *field in self.allFields) {
    [self.fieldsView addSubview:field];
  }

  [self.boundedView addSubview:self.brandImageView];

  self.expirationField.alpha = 0;
  self.cvcField.alpha = 0;
  self.postalCodeField.alpha = 0;

  _sizingField = [self buildSizingTextField];
  _sizingField.font = self.font;
  _sizingField.formDelegate = nil;
  _sizingLabel = [UILabel new];

  self.focusedTextFieldForLayout = nil;
}

#pragma mark Setters and Getters

- (CardFormViewModel *)viewModel {
  if (_viewModel == nil) {
    _viewModel = [CardFormViewModel new];
  }
  return _viewModel;
}

- (SingleLineCardImageManager *)imageManager {
  if (_imageManager == nil) {
    _imageManager = [[SingleLineCardImageManager alloc] init];
  }
  return _imageManager;
}

- (SPCardFormFieldEditingTransitionManager *)fieldEditingTransitionManager {
  if (_fieldEditingTransitionManager == nil) {
    _fieldEditingTransitionManager = [[SPCardFormFieldEditingTransitionManager alloc] init];
  }
  return _fieldEditingTransitionManager;
}

#pragma mark appearance properties

- (UIColor *)backgroundColor {
  return [super backgroundColor] ?: [UIColor systemBackgroundColor];
}

- (UIFont *)font {
  return [UIFont systemFontOfSize:18];
}

- (void)setContentVerticalAlignment:
(UIControlContentVerticalAlignment)contentVerticalAlignment {
  [super setContentVerticalAlignment:contentVerticalAlignment];
  for (UITextField *field in [self allFields]) {
    field.contentVerticalAlignment = contentVerticalAlignment;
  }
  switch (contentVerticalAlignment) {
    case UIControlContentVerticalAlignmentCenter:
      self.brandImageView.contentMode = UIViewContentModeCenter;
      break;
    case UIControlContentVerticalAlignmentBottom:
      self.brandImageView.contentMode = UIViewContentModeBottom;
      break;
    case UIControlContentVerticalAlignmentFill:
      self.brandImageView.contentMode = UIViewContentModeTop;
      break;
    case UIControlContentVerticalAlignmentTop:
      self.brandImageView.contentMode = UIViewContentModeTop;
      break;
  }
}

- (UIColor *)textColor {
  return [UIColor darkTextColor];
}

- (UIColor *)textErrorColor {
  return [UIColor systemRedColor];;
}

- (UIColor *)placeholderColor {
  return [UIColor systemGray2Color];
}

- (void)setNumberPlaceholder:(NSString *__nullable)numberPlaceholder {
  _numberPlaceholder = [numberPlaceholder copy];
  self.numberField.placeholder = _numberPlaceholder;
}

- (void)setExpirationPlaceholder:(NSString *__nullable)expirationPlaceholder {
  _expirationPlaceholder = [expirationPlaceholder copy];
  self.expirationField.placeholder = _expirationPlaceholder;
}

- (void)setCvcPlaceholder:(NSString *__nullable)cvcPlaceholder {
  _cvcPlaceholder = [cvcPlaceholder copy];
  self.cvcField.placeholder = _cvcPlaceholder;
}

- (void)setPostalCodePlaceholder:(NSString *)postalCodePlaceholder {
  _postalCodePlaceholder = postalCodePlaceholder.copy;
  [self updatePostalFieldPlaceholder];
}

- (BOOL)postalCodeEntryDisplayed {
  return self.viewModel.postalCodeDisplayed;
}

- (BOOL)postalCodeEntryRequired {
  return self.viewModel.postalCodeRequired;
}

- (BOOL)cvcEntryDisplayed {
  return self.viewModel.cvcDisplayed;
}

- (BOOL)cvcEntryRequired {
  return self.viewModel.cvcRequired;
}

- (NSString *)countryCode {
  return self.viewModel.postalCodeCountryCode;
}

- (void)setCountryCode:(NSString *)cCode {
  NSString *countryCode = cCode ?: [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];

  self.viewModel.postalCodeCountryCode = countryCode;
  [self updatePostalFieldPlaceholder];

  if ([countryCode isEqualToString:@"US"]) {
    self.postalCodeField.keyboardType = UIKeyboardTypePhonePad;
  } else {
    self.postalCodeField.keyboardType = UIKeyboardTypeDefault;
  }

  // This will revalidate and reformat
  [self setText:self.postalCode inField:SPCardFieldTypePostalCode];
}

- (void)updatePostalFieldPlaceholder {
  if (self.postalCodePlaceholder == nil) {
    self.postalCodeField.placeholder = [self defaultPostalFieldPlaceholderForCountryCode:self.countryCode];
  } else {
    self.postalCodeField.placeholder = _postalCodePlaceholder;
  }
}

#pragma mark UIControl

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  for (SPFormTextField *textField in [self allFields]) {
    textField.enabled = enabled;
  };
}

#pragma mark UIResponder & related methods

- (BOOL)isFirstResponder {
  return self.currentFirstResponderField != nil;
}

- (BOOL)canBecomeFirstResponder {
  SPFormTextField *firstResponder = [self currentFirstResponderField] ?: [self nextFirstResponderField];
  return [firstResponder canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
  SPFormTextField *firstResponder = [self currentFirstResponderField] ?: [self nextFirstResponderField];
  return [firstResponder becomeFirstResponder];
}

/**
 Returns the next text field to be edited, in priority order:

 1. If we're currently in a text field, returns the next one (ignoring
 postalCodeField if postalCodeEntryDisplayed == NO and cvcField if cvcEntryDisplayed == NO)
 2. Otherwise, returns the first invalid field (either cycling back from the end
 or as it gains 1st responder)
 3. As a final fallback, just returns the last field
 */
- (nonnull SPFormTextField *)nextFirstResponderField {
  SPFormTextField *currentFirstResponder = [self currentFirstResponderField];
  SPFormTextField *nextField = nil;

  if (currentFirstResponder) {
    NSUInteger index = [self.allFields indexOfObject:currentFirstResponder];
    if (index != NSNotFound) {
      nextField = [self.allFields sp_boundSafeObjectAtIndex:index + 1];
    }
  }

  if (nextField &&
      (self.postalCodeEntryDisplayed || nextField != self.postalCodeField) &&
      (self.cvcEntryDisplayed || nextField != self.cvcField)) {
    return nextField;
  }

  return [self firstInvalidSubField] ?: [self lastSubField];
}

- (nullable SPFormTextField *)firstInvalidSubField {
  if ([self.viewModel isFieldValid:SPCardFieldTypeNumber] == NO) {
    return self.numberField;
  } else if ([self.viewModel isFieldValid:SPCardFieldTypeExpiration] == NO) {
    return self.expirationField;
  } else if (self.cvcEntryRequired && [self.viewModel isFieldValid:SPCardFieldTypeCVC] == NO) {
    return self.cvcField;
  } else if (self.postalCodeEntryRequired && [self.viewModel isFieldValid:SPCardFieldTypePostalCode] == NO) {
    return self.postalCodeField;
  } else {
    return nil;
  }
}

- (nonnull SPFormTextField *)lastSubField {
  if (self.postalCodeEntryDisplayed) {
    return self.postalCodeField;
  } else if (self.cvcEntryDisplayed) {
    return self.cvcField;;
  } else {
    return self.expirationField;
  }
}

- (SPFormTextField *)currentFirstResponderField {
  for (SPFormTextField *textField in [self allFields]) {
    if ([textField isFirstResponder]) {
      return textField;
    }
  }
  return nil;
}

- (SPFormTextField *)previousField {
  SPFormTextField *currentSubResponder = self.currentFirstResponderField;
  if (currentSubResponder) {
    NSUInteger index = [self.allFields indexOfObject:currentSubResponder];
    if (index != NSNotFound && index > 0) {
      return self.allFields[index - 1];
    }
  }
  return nil;
}

- (NSString *)cardNumber {
  return self.viewModel.cardNumber;
}

- (NSUInteger)expirationMonth {
  return [self.viewModel.expirationMonth integerValue];
}

- (NSUInteger)expirationYear {
  return [self.viewModel.expirationYear integerValue];
}

- (NSString *)formattedExpirationMonth {
  return self.viewModel.expirationMonth;
}

- (NSString *)formattedExpirationYear {
  return self.viewModel.expirationYear;
}

- (NSString *)formattedExpirationDate {
  return [self.viewModel.expirationMonth
          stringByAppendingFormat:@"/%@", self.viewModel.expirationYear];
}

- (NSString *)cvc {
  if (self.cvcEntryDisplayed) {
    return self.viewModel.cvc;
  } else {
    return nil;
  }
}

- (NSString *)postalCode {
  if (self.postalCodeEntryDisplayed) {
    return self.viewModel.postalCode;
  } else {
    return nil;
  }
}

- (BOOL)canResignFirstResponder {
  return [self.currentFirstResponderField canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
  BOOL success = [self.currentFirstResponderField resignFirstResponder];
  [self updateImageForFieldType:SPCardFieldTypeNumber];

  [self layoutViewsToFocusField:nil
           becomeFirstResponder:NO
                       animated:YES
                     completion:nil];

  return success;
}

#pragma mark public convenience methods

- (void)clear {

  for (SPFormTextField *field in [self allFields]) {
    field.text = @"";
  }

  self.viewModel.cardNumber = nil;
  self.viewModel.rawExpiration = nil;
  self.viewModel.cvc = nil;
  self.viewModel.postalCode = nil;

  [self onChange];
  [self updateImageForFieldType:SPCardFieldTypeNumber];
  [self updateCVCPlaceholder];

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

- (void)setCVCDisplayConfig:(CardFieldDisplay)displayConfig {
  self.viewModel.cvcDisplayed = displayConfig != CardFieldDisplayNone;
  self.viewModel.cvcRequired = displayConfig == CardFieldDisplayRequired;
}

- (void)setPostalCodeDisplayConfig:(CardFieldDisplay)displayConfig {
  self.viewModel.postalCodeDisplayed = displayConfig != CardFieldDisplayNone;
  self.viewModel.postalCodeRequired = displayConfig == CardFieldDisplayRequired;
}

- (BOOL)isValid {
  return [self.viewModel isValid];
}


#pragma mark private

- (void)setText:(NSString *)text inField:(SPCardFieldType)field {
  NSString *nonNilText = text ?: @"";
  SPFormTextField *textField = nil;
  switch (field) {
    case SPCardFieldTypeNumber:
      textField = self.numberField;
      break;
    case SPCardFieldTypeExpiration:
      textField = self.expirationField;
      break;
    case SPCardFieldTypeCVC:
      textField = self.cvcField;
      break;
    case SPCardFieldTypePostalCode:
      textField = self.postalCodeField;
      break;
  }
  textField.text = nonNilText;
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
  return CGRectMake(SingleLineCardFormDefaultPadding, 
                    -1,
                    self.brandImageView.image.size.width, 
                    bounds.size.height);
}

- (CGRect)fieldsRectForBounds:(CGRect)bounds {
  CGRect brandImageRect = [self brandImageRectForBounds:bounds];
  return CGRectMake(CGRectGetMaxX(brandImageRect), 
                    0,
                    CGRectGetWidth(bounds) - CGRectGetMaxX(brandImageRect),
                    CGRectGetHeight(bounds));
}

- (CGRect)boundedViewRectForBounds {
  return CGRectMake(0,
                    (CGRectGetHeight(self.bounds) - SingleLineCardFormBoundsMaximumHeight) / 2,
                    CGRectGetWidth(self.bounds),
                    SingleLineCardFormBoundsMaximumHeight);
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self recalculateSubviewLayout];
}

- (void)recalculateSubviewLayout {

  self.boundedView.frame = [self boundedViewRectForBounds];

  self.brandImageView.frame = [self brandImageRectForBounds:self.boundedView.bounds];
  CGRect fieldsViewRect = [self fieldsRectForBounds:self.boundedView.bounds];
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
      maskView.backgroundColor = self.textColor;
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

- (SPFormTextField *)buildTextField {
  SPFormTextField *textField =
  [[SPFormTextField alloc] initWithFrame:CGRectZero];
  textField.backgroundColor = [UIColor clearColor];
  // setCountryCode: updates the postalCodeField keyboardType, this is safe
  textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
  textField.textAlignment = NSTextAlignmentLeft;
  textField.font = self.font;
  textField.defaultColor = self.textColor;
  textField.errorColor = self.textErrorColor;
  textField.placeholderColor = self.placeholderColor;
  textField.formDelegate = self;
  textField.validText = true;
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  return textField;
}
- (void)clearSizingCache {
  self.textToWidthCache = [NSMutableDictionary new];
  self.numberToWidthCache = [NSMutableDictionary new];
}

- (NSString *)defaultPostalFieldPlaceholderForCountryCode:(NSString *)countryCode {
  if ([countryCode.uppercaseString isEqualToString:@"US"]) {
    return @"ZIP";
  } else {
    return @"Postal";
  }
}

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

#pragma mark SPFormTextFieldDelegate

- (void)formTextFieldDidBackspaceOnEmpty:(__unused SPFormTextField *)formTextField {
  SPFormTextField *previous = [self previousField];
  [previous becomeFirstResponder];

  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  
  if (previous.hasText) {
    [previous deleteBackward];
  }
}

- (NSAttributedString *)formTextField:(SPFormTextField *)formTextField
             modifyIncomingTextChange:(NSAttributedString *)input {
  SPCardFieldType fieldType = formTextField.tag;
  switch (fieldType) {
    case SPCardFieldTypeNumber:
      self.viewModel.cardNumber = input.string;
      [self setNeedsLayout];
      break;
    case SPCardFieldTypeExpiration:
      self.viewModel.rawExpiration = input.string;
      break;
    case SPCardFieldTypeCVC:
      self.viewModel.cvc = input.string;
      break;
    case SPCardFieldTypePostalCode:
      self.viewModel.postalCode = input.string;
      [self setNeedsLayout];
      break;
  }

  switch (fieldType) {
    case SPCardFieldTypeNumber:
      return [[NSAttributedString alloc]
              initWithString:self.viewModel.cardNumber
              attributes:self.numberField.defaultTextAttributes];
    case SPCardFieldTypeExpiration:
      return [[NSAttributedString alloc]
              initWithString:self.viewModel.rawExpiration
              attributes:self.expirationField.defaultTextAttributes];
    case SPCardFieldTypeCVC:
      return [[NSAttributedString alloc]
              initWithString:self.viewModel.cvc
              attributes:self.cvcField.defaultTextAttributes];
    case SPCardFieldTypePostalCode:
      return [[NSAttributedString alloc]
              initWithString:self.viewModel.postalCode
              attributes:self.cvcField.defaultTextAttributes];
  }
}

- (void)formTextFieldTextDidChange:(SPFormTextField *)formTextField {
  SPCardFieldType fieldType = formTextField.tag;

  if (fieldType == SPCardFieldTypeNumber) {
    [self updateImageForFieldType:fieldType];
    [self updateCVCPlaceholder];
    // Changing the card number field can invalidate the cvc, e.g. going from 4
    // digit Amex cvc to 3 digit Visa
    self.cvcField.validText =
    [self.viewModel validationStateForField:SPCardFieldTypeCVC] != SPCardValidationStateInvalid;
  }

  SPCardValidationState state = [self.viewModel validationStateForField:fieldType];
  formTextField.validText = YES;
  switch (state) {
    case SPCardValidationStateInvalid:
      formTextField.validText = NO;
      break;
    case SPCardValidationStateIncomplete:
      break;
    case SPCardValidationStateValid: {
      if (fieldType == SPCardFieldTypeCVC) {
        /*
         Even though any CVC longer than the min required CVC length
         is valid, we don't want to forward on to the next field
         unless it is actually >= the max cvc length (otherwise when
         postal code is showing, you can't easily enter CVCs longer than
         the minimum.
         */
        NSString *sanitizedCvc = [SPCardValidator sanitizedNumericStringForString:formTextField.text];
        if (sanitizedCvc.length < [SPCardValidator maxCVCLengthForCardBrand:self.viewModel.brand]) {
          break;
        }
      } else if (fieldType == SPCardFieldTypePostalCode) {
        /*
         Similar to the UX problems on CVC, since our Postal Code validation
         is pretty light, we want to block auto-advance here. In the US, this
         allows users to enter 9 digit zips if they want, and as many as they
         need in non-US countries (where >0 characters is "valid")
         */
        break;
      }

      // This is a no-op if this is the last field & they're all valid
      [[self nextFirstResponderField] becomeFirstResponder];

      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);

      break;
    }
  }

  [self onChange];
}

- (BOOL)textFieldShouldBeginEditing:(__unused UITextField *)textField {
  [self.fieldEditingTransitionManager getAndUpdateStateFromCall:SPFieldEditingTransitionCallSiteShouldBegin];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  BOOL isMidSubviewEditingTransition =
  [self.fieldEditingTransitionManager getAndUpdateStateFromCall:SPFieldEditingTransitionCallSiteDidBegin];

  [self layoutViewsToFocusField:@(textField.tag)
           becomeFirstResponder:YES
                       animated:YES
                     completion:nil];

  if (!isMidSubviewEditingTransition) {
    if ([self.delegate respondsToSelector:@selector(cardFormDidBeginEditing:)]) {
      [self.delegate cardFormDidBeginEditing:self];
    }
  }

  SPCardFieldType fieldType = (SPCardFieldType)textField.tag;

  if (fieldType == SPCardFieldTypeNumber) {
    ((SPFormTextField *)textField).validText = YES;
  }

  if ([self.delegate respondsToSelector:@selector(cardForm:didBeginEditingField:)]) {
    [self.delegate cardForm:self didBeginEditingField:fieldType];
  }

  [self updateImageForFieldType:textField.tag];
}

- (BOOL)textFieldShouldEndEditing:(__unused UITextField *)textField {
  [self.fieldEditingTransitionManager getAndUpdateStateFromCall:
   SPFieldEditingTransitionCallSiteShouldEnd];
  [self updateImageForFieldType:SPCardFieldTypeNumber];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  BOOL isMidSubviewEditingTransition =
  [self.fieldEditingTransitionManager getAndUpdateStateFromCall:SPFieldEditingTransitionCallSiteDidEnd];

  SPCardFieldType fieldType = (SPCardFieldType)textField.tag;

  if (fieldType == SPCardFieldTypeNumber) {
    SPCardValidationState validationState = [self.viewModel validationStateForField:SPCardFieldTypeNumber];

    if (validationState == SPCardValidationStateIncomplete) {
      ((SPFormTextField *)textField).validText = NO;
    }
  }

  if ([self.delegate respondsToSelector:@selector(cardForm:didEndEditingField:)]) {
    [self.delegate cardForm:self didEndEditingField:fieldType];
  }

  if (!isMidSubviewEditingTransition) {
    [self layoutViewsToFocusField:nil
             becomeFirstResponder:NO
                         animated:YES
                       completion:nil];

    [self updateImageForFieldType:SPCardFieldTypeNumber];
    
    if ([self.delegate respondsToSelector:@selector(cardFormDidEndEditing:)]) {
      [self.delegate cardFormDidEndEditing:self];
    }
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == [self lastSubField] && [self firstInvalidSubField] == nil) {
    // User pressed return in the last field, and all fields are valid
    if ([self.delegate respondsToSelector:@selector
         (cardFormWillEndEditingForReturn:)]) {
      [self.delegate cardFormWillEndEditingForReturn:self];
    }
    [self resignFirstResponder];
  } else {
    // otherwise, move to the next field
    [[self nextFirstResponderField] becomeFirstResponder];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                    nil);
  }

  return NO;
}

- (UIImage *)brandImage {
  return self.brandImageView.image;
}

- (void)updateImageForFieldType:(SPCardFieldType)fieldType {
  [self.imageManager updateImageView:self.brandImageView
                                    fieldType:fieldType
                                        brand:self.viewModel.brand
                                   validation:[self.viewModel validationStateForField:fieldType]];
}

- (NSString *)defaultCVCPlaceholder {
  if (self.viewModel.brand == SPCardBrandAmex) {
    return @"CVV";
  } else {
    return @"CVC";
  }
}

- (void)updateCVCPlaceholder {
  if (self.cvcPlaceholder) {
    self.cvcField.placeholder = self.cvcPlaceholder;
    self.cvcField.accessibilityLabel = self.cvcPlaceholder;
  } else {
    self.cvcField.placeholder = [self defaultCVCPlaceholder];
    self.cvcField.accessibilityLabel = [self defaultCVCPlaceholder];
  }
}

- (void)onChange {
  if ([self.delegate respondsToSelector:@selector(cardFormDidChange:)]) {
    [self.delegate cardFormDidChange:self];
  }
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark UIKeyInput

- (BOOL)hasText {
  return self.numberField.hasText || self.expirationField.hasText ||
  self.cvcField.hasText;
}

- (void)insertText:(NSString *)text {
  [self.currentFirstResponderField insertText:text];
}

- (void)deleteBackward {
  [self.currentFirstResponderField deleteBackward];
}

@end
