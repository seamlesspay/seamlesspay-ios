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
#import "CardForm.h"
#import "CardFormViewModel.h"
#import "CardLogoImageViewManager.h"

@interface CardForm () <SPFormTextFieldDelegate>

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
@property(nonatomic, copy, nullable) NSString *numberPlaceholder;
@property(nonatomic, copy, nullable) NSString *expirationPlaceholder;
@property(nonatomic, copy, nullable) NSString *cvcPlaceholder;
@property(nonatomic, copy, nullable) NSString *postalCodePlaceholder;

@property(nonatomic, strong) CardLogoImageViewManager *cardLogoImageViewManager;

/**
 These bits lets us track beginEditing and endEditing for payment text field
 as a whole (instead of on a per-subview basis).

 DO NOT read this values directly. Use the return value from
 `getAndUpdateSubviewEditingTransitionStateFromCall:` which updates them all
 and returns you the correct current state for the method you are in.

 The state transitons in the should/did begin/end editing callbacks for all
 our subfields. If we get a shouldEnd AND a shouldBegin before getting either's
 matching didEnd/didBegin, then we are transitioning focus between our subviews
 (and so we ourselves should not consider us to have begun or ended editing).

 But if we get a should and did called on their own without a matching opposite
 pair (shouldBegin/didBegin or shouldEnd/didEnd) then we are transitioning
 into/out of our subviews from/to outside of ourselves
 */
@property(nonatomic, assign) BOOL isMidSubviewEditingTransitionInternal;
@property(nonatomic, assign) BOOL receivedUnmatchedShouldBeginEditing;
@property(nonatomic, assign) BOOL receivedUnmatchedShouldEndEditing;

@end

@implementation CardForm

@dynamic enabled;

#pragma mark Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit {

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
  boundedView.backgroundColor = [UIColor clearColor];
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
  [self resetSubviewEditingTransitionState];
  self.countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
}

- (CardFormViewModel *)viewModel {
  if (_viewModel == nil) {
    _viewModel = [CardFormViewModel new];
  }
  return _viewModel;
}

- (CardLogoImageViewManager *)cardLogoImageViewManager {
  if (_cardLogoImageViewManager == nil) {
    _cardLogoImageViewManager = [[CardLogoImageViewManager alloc] init];
  }
  return _cardLogoImageViewManager;
}

#pragma mark appearance properties

- (UIColor *)backgroundColor {
  UIColor *defaultColor = [UIColor whiteColor];
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    defaultColor = [UIColor systemBackgroundColor];
  }
#endif

  return [super backgroundColor] ?: defaultColor;
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
  UIColor *defaultColor = [UIColor blackColor];
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    defaultColor = [UIColor labelColor];
  }
#endif

  return defaultColor;
}

- (UIColor *)textErrorColor {
  UIColor *defaultColor = [UIColor redColor];
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    defaultColor = [UIColor systemRedColor];
  }
#endif

  return defaultColor;
}

- (UIColor *)placeholderColor {
#ifdef __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    return [UIColor systemGray2Color];
  }
#endif

  return [UIColor lightGrayColor];
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

- (NSString *)defaultPostalFieldPlaceholderForCountryCode:(NSString *)countryCode {
  if ([countryCode.uppercaseString isEqualToString:@"US"]) {
    return @"ZIP";
  } else {
    return @"Postal";
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
  SPFormTextField *firstResponder =
  [self currentFirstResponderField] ?: [self nextFirstResponderField];
  return [firstResponder canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
  SPFormTextField *firstResponder =
  [self currentFirstResponderField] ?: [self nextFirstResponderField];
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

- (BOOL)canResignFirstResponder {
  return [self.currentFirstResponderField canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
  [super resignFirstResponder];
  BOOL success = [self.currentFirstResponderField resignFirstResponder];
  [self updateImageForFieldType:SPCardFieldTypeNumber];
  return success;
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

#pragma mark public convenience methods

- (void)clear {
  for (SPFormTextField *field in [self allFields]) {
    field.text = @"";
  }
  self.viewModel = [CardFormViewModel new];
  [self onChange];
  [self updateImageForFieldType:SPCardFieldTypeNumber];
  [self updateCVCPlaceholder];
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

- (BOOL)valid {
  return self.isValid;
}

#pragma mark readonly variables

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

#pragma mark - Private

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
  return textField;
}

typedef NS_ENUM(NSInteger, SPFieldEditingTransitionCallSite) {
  SPFieldEditingTransitionCallSiteShouldBegin,
  SPFieldEditingTransitionCallSiteShouldEnd,
  SPFieldEditingTransitionCallSiteDidBegin,
  SPFieldEditingTransitionCallSiteDidEnd,
};

// Explanation of the logic here is with the definition of these properties
// at the top of this file
- (BOOL)getAndUpdateSubviewEditingTransitionStateFromCall:
(SPFieldEditingTransitionCallSite)sendingMethod {
  BOOL stateToReturn;
  switch (sendingMethod) {
    case SPFieldEditingTransitionCallSiteShouldBegin:
      self.receivedUnmatchedShouldBeginEditing = YES;
      if (self.receivedUnmatchedShouldEndEditing) {
        self.isMidSubviewEditingTransitionInternal = YES;
      }
      stateToReturn = self.isMidSubviewEditingTransitionInternal;
      break;
    case SPFieldEditingTransitionCallSiteShouldEnd:
      self.receivedUnmatchedShouldEndEditing = YES;
      if (self.receivedUnmatchedShouldBeginEditing) {
        self.isMidSubviewEditingTransitionInternal = YES;
      }
      stateToReturn = self.isMidSubviewEditingTransitionInternal;
      break;
    case SPFieldEditingTransitionCallSiteDidBegin:
      stateToReturn = self.isMidSubviewEditingTransitionInternal;
      self.receivedUnmatchedShouldBeginEditing = NO;

      if (self.receivedUnmatchedShouldEndEditing == NO) {
        self.isMidSubviewEditingTransitionInternal = NO;
      }
      break;
    case SPFieldEditingTransitionCallSiteDidEnd:
      stateToReturn = self.isMidSubviewEditingTransitionInternal;
      self.receivedUnmatchedShouldEndEditing = NO;

      if (self.receivedUnmatchedShouldBeginEditing == NO) {
        self.isMidSubviewEditingTransitionInternal = NO;
      }
      break;
  }

  return stateToReturn;
}

#pragma mark SPFormTextFieldDelegate

- (void)formTextFieldDidBackspaceOnEmpty:
(__unused SPFormTextField *)formTextField {
  SPFormTextField *previous = [self previousField];
  [previous becomeFirstResponder];
  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                  nil);
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
    [self.viewModel validationStateForField:SPCardFieldTypeCVC] !=
    SPCardValidationStateInvalid;
  }

  SPCardValidationState state =
  [self.viewModel validationStateForField:fieldType];
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
        NSString *sanitizedCvc =
        [SPCardValidator sanitizedNumericStringForString:formTextField.text];
        if (sanitizedCvc.length <
            [SPCardValidator maxCVCLengthForCardBrand:self.viewModel.brand]) {
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
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                      nil);

      break;
    }
  }

  [self onChange];
}

- (void)resetSubviewEditingTransitionState {
  self.isMidSubviewEditingTransitionInternal = NO;
  self.receivedUnmatchedShouldBeginEditing = NO;
  self.receivedUnmatchedShouldEndEditing = NO;
}

- (BOOL)textFieldShouldBeginEditing:(__unused UITextField *)textField {
  [self getAndUpdateSubviewEditingTransitionStateFromCall:
   SPFieldEditingTransitionCallSiteShouldBegin];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  BOOL isMidSubviewEditingTransition =
  [self getAndUpdateSubviewEditingTransitionStateFromCall:
   SPFieldEditingTransitionCallSiteDidBegin];

  //TODO: Add to SingleLineCardForm
//  [self layoutViewsToFocusField:@(textField.tag)
//           becomeFirstResponder:YES
//                       animated:YES
//                     completion:nil];

  if (!isMidSubviewEditingTransition) {
    if ([self.delegate respondsToSelector:@selector
         (cardFormDidBeginEditing:)]) {
      [self.delegate cardFormDidBeginEditing:self];
    }
  }

  switch ((SPCardFieldType)textField.tag) {
    case SPCardFieldTypeNumber:
      ((SPFormTextField *)textField).validText = YES;
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidBeginEditingNumber:)]) {
        [self.delegate cardFormDidBeginEditingNumber:self];
      }
      break;
    case SPCardFieldTypeCVC:
      if ([self.delegate respondsToSelector:@selector
           (cardFormBeginEditingCVC:)]) {
        [self.delegate cardFormBeginEditingCVC:self];
      }
      break;
    case SPCardFieldTypeExpiration:
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidBeginEditingExpiration:)]) {
        [self.delegate cardFormDidBeginEditingExpiration:self];
      }
      break;
    case SPCardFieldTypePostalCode:
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidBeginEditingPostalCode:)]) {
        [self.delegate cardFormDidBeginEditingPostalCode:self];
      }
      break;
  }
  [self updateImageForFieldType:textField.tag];
}

- (BOOL)textFieldShouldEndEditing:(__unused UITextField *)textField {
  [self getAndUpdateSubviewEditingTransitionStateFromCall:
   SPFieldEditingTransitionCallSiteShouldEnd];
  [self updateImageForFieldType:SPCardFieldTypeNumber];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  BOOL isMidSubviewEditingTransition =
  [self getAndUpdateSubviewEditingTransitionStateFromCall:
   SPFieldEditingTransitionCallSiteDidEnd];

  switch ((SPCardFieldType)textField.tag) {
    case SPCardFieldTypeNumber:
      if ([self.viewModel validationStateForField:SPCardFieldTypeNumber] ==
          SPCardValidationStateIncomplete) {
        ((SPFormTextField *)textField).validText = NO;
      }
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidEndEditingNumber:)]) {
        [self.delegate cardFormDidEndEditingNumber:self];
      }
      break;
    case SPCardFieldTypeCVC:
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidEndEditingCVC:)]) {
        [self.delegate cardFormDidEndEditingCVC:self];
      }
      break;
    case SPCardFieldTypeExpiration:
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidEndEditingExpiration:)]) {
        [self.delegate cardFormDidEndEditingExpiration:self];
      }
      break;
    case SPCardFieldTypePostalCode:
      if ([self.delegate respondsToSelector:@selector
           (cardFormDidEndEditingPostalCode:)]) {
        [self.delegate cardFormDidEndEditingPostalCode:self];
      }
      break;
  }

  if (!isMidSubviewEditingTransition) {
    //TODO: Add to SingleLineCardForm
//    [self layoutViewsToFocusField:nil
//             becomeFirstResponder:NO
//                         animated:YES
//                       completion:nil];
    [self updateImageForFieldType:SPCardFieldTypeNumber];
    if ([self.delegate
         respondsToSelector:@selector(cardFormDidEndEditing:)]) {
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
  [self.cardLogoImageViewManager updateImageView:self.brandImageView
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
