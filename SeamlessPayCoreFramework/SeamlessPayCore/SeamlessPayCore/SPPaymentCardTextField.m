//
//  SPPaymentCardTextField.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <UIKit/UIKit.h>

#import "SPPaymentCardTextField.h"

#import "NSArray+Extras.h"
#import "NSString+Extras.h"
#import "SPCardValidator+Extras.h"

#import "SPFormTextField.h"
#import "SPImageLibrary.h"
#import "SPPaymentCardTextFieldViewModel.h"
#import "SPPaymentMethodCardParams.h"


@interface SPPaymentCardTextField()<SPFormTextFieldDelegate>

@property (nonatomic, readwrite, weak) UIImageView *brandImageView;
@property (nonatomic, readwrite, weak) UIView *fieldsView;
@property (nonatomic, readwrite, weak) SPFormTextField *numberField;
@property (nonatomic, readwrite, weak) SPFormTextField *expirationField;
@property (nonatomic, readwrite, weak) SPFormTextField *cvcField;
@property (nonatomic, readwrite, weak) SPFormTextField *postalCodeField;
@property (nonatomic, readwrite, strong) SPPaymentCardTextFieldViewModel *viewModel;
@property (nonatomic, readwrite, strong) SPPaymentMethodCardParams *internalCardParams;
@property (nonatomic, strong) NSArray<SPFormTextField *> *allFields;
@property (nonatomic, readwrite, strong) SPFormTextField *sizingField;
@property (nonatomic, readwrite, strong) UILabel *sizingLabel;

/*
 These track the input parameters to the brand image setter so that we can
 later perform proper transition animations when new values are set
 */
@property (nonatomic, assign) SPCardFieldType currentBrandImageFieldType;
@property (nonatomic, assign) SPCardBrand currentBrandImageBrand;

/**
 This is a number-wrapped SPCardFieldType (or nil) that layout uses
 to determine how it should move/animate its subviews so that the chosen
 text field is fully visible.
 */
@property (nonatomic, copy) NSNumber *focusedTextFieldForLayout;

/*
 Creating and measuring the size of attributed strings is expensive so
 cache the values here.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *textToWidthCache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *numberToWidthCache;

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
@property (nonatomic, assign) BOOL isMidSubviewEditingTransitionInternal;
@property (nonatomic, assign) BOOL receivedUnmatchedShouldBeginEditing;
@property (nonatomic, assign) BOOL receivedUnmatchedShouldEndEditing;

@end

NS_INLINE CGFloat sp_ceilCGFloat(CGFloat x) {
#if CGFLOAT_IS_DOUBLE
    return ceil(x);
#else
    return ceilf(x);
#endif
}


@implementation SPPaymentCardTextField

@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize textErrorColor = _textErrorColor;
@synthesize placeholderColor = _placeholderColor;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize cornerRadius = _cornerRadius;
@dynamic enabled;

CGFloat const SPPaymentCardTextFieldDefaultPadding = 13;
CGFloat const SPPaymentCardTextFieldDefaultInsets = 13;
CGFloat const SPPaymentCardTextFieldMinimumPadding = 10;

#pragma mark initializers

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
    // We're using ivars here because UIAppearance tracks when setters are
    // called, and won't override properties that have already been customized
    _borderColor = [self.class placeholderGrayColor];
    _cornerRadius = 5.0f;
    _borderWidth = 1.0f;
    self.layer.borderColor = [[_borderColor copy] CGColor];
    self.layer.cornerRadius = _cornerRadius;
    self.layer.borderWidth = _borderWidth;

    self.clipsToBounds = YES;

    _internalCardParams = [SPPaymentMethodCardParams new];
    _viewModel = [SPPaymentCardTextFieldViewModel new];
    _sizingField = [self buildTextField];
    _sizingField.formDelegate = nil;
    _sizingLabel = [UILabel new];
    
    UIImageView *brandImageView = [[UIImageView alloc] initWithImage:self.brandImage];
    brandImageView.contentMode = UIViewContentModeCenter;
    brandImageView.backgroundColor = [UIColor clearColor];
    brandImageView.tintColor = self.placeholderColor;
    self.brandImageView = brandImageView;
    
    SPFormTextField *numberField = [self buildTextField];
    // This does not offer quick-type suggestions (as iOS 11.2), but does pick
    // the best keyboard (maybe other, hidden behavior?)
    numberField.textContentType = UITextContentTypeCreditCardNumber;
    numberField.autoFormattingBehavior = SPFormTextFieldAutoFormattingBehaviorCardNumbers;
    numberField.tag = SPCardFieldTypeNumber;
    numberField.accessibilityLabel = @"card number";
    self.numberField = numberField;
    self.numberPlaceholder = [self.viewModel defaultPlaceholder];

    SPFormTextField *expirationField = [self buildTextField];
    expirationField.autoFormattingBehavior = SPFormTextFieldAutoFormattingBehaviorExpiration;
    expirationField.tag = SPCardFieldTypeExpiration;
    expirationField.alpha = 0;
    expirationField.isAccessibilityElement = NO;
    expirationField.accessibilityLabel = @"expiration date";
    self.expirationField = expirationField;
    self.expirationPlaceholder = @"MM/YY";
        
    SPFormTextField *cvcField = [self buildTextField];
    cvcField.tag = SPCardFieldTypeCVC;
    cvcField.alpha = 0;
    cvcField.isAccessibilityElement = NO;
    self.cvcField = cvcField;
    self.cvcPlaceholder = nil;
    self.cvcField.accessibilityLabel = [self defaultCVCPlaceholder];

    SPFormTextField *postalCodeField = [self buildTextField];
    postalCodeField.textContentType = UITextContentTypePostalCode;
    postalCodeField.tag = SPCardFieldTypePostalCode;
    postalCodeField.alpha = 0;
    postalCodeField.isAccessibilityElement = NO;
    self.postalCodeField = postalCodeField;
    // Placeholder and appropriate keyboard typeare set by country code setter

    UIView *fieldsView = [[UIView alloc] init];
    fieldsView.clipsToBounds = YES;
    fieldsView.backgroundColor = [UIColor clearColor];
    self.fieldsView = fieldsView;

    self.allFields = @[numberField,
                       expirationField,
                       cvcField,
                       postalCodeField];
    
    [self addSubview:self.fieldsView];
    for (SPFormTextField *field in self.allFields) {
        [self.fieldsView addSubview:field];
    }

    [self addSubview:brandImageView];
    // On small screens, the number field fits ~4 numbers, and the brandImage is just as large.
    // Previously, taps on the brand image would *dismiss* the keyboard. Make it move to the numberField instead
    brandImageView.userInteractionEnabled = YES;
    [brandImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:numberField
                                                                                 action:@selector(becomeFirstResponder)]];

    self.focusedTextFieldForLayout = nil;
    [self updateCVCPlaceholder];
    [self resetSubviewEditingTransitionState];
}

- (SPPaymentCardTextFieldViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [SPPaymentCardTextFieldViewModel new];
    }
    return _viewModel;
}

#pragma mark appearance properties

- (void)clearSizingCache {
    self.textToWidthCache = [NSMutableDictionary new];
    self.numberToWidthCache = [NSMutableDictionary new];
}

+ (UIColor *)placeholderGrayColor {
    #ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return [UIColor systemGray2Color];
        }
    #endif
    
    return [UIColor lightGrayColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[backgroundColor copy]];
    self.numberField.backgroundColor = self.backgroundColor;
}

- (UIColor *)backgroundColor {
    UIColor *defaultColor = [UIColor whiteColor];
    #ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            defaultColor = [UIColor systemBackgroundColor];
        }
    #endif
    
    return [super backgroundColor] ?: defaultColor;
}

- (void)setFont:(UIFont *)font {
    _font = [font copy];
    
    for (UITextField *field in [self allFields]) {
        field.font = _font;
    }
    
    self.sizingField.font = _font;
    [self clearSizingCache];
    
    [self setNeedsLayout];
}

- (UIFont *)font {
    return _font ?: [UIFont systemFontOfSize:18];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = [textColor copy];
    
    for (SPFormTextField *field in [self allFields]) {
        field.defaultColor = _textColor;
    }
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
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

    return _textColor ?: defaultColor;
}

- (void)setTextErrorColor:(UIColor *)textErrorColor {
    _textErrorColor = [textErrorColor copy];
    
    for (SPFormTextField *field in [self allFields]) {
        field.errorColor = _textErrorColor;
    }
}

- (UIColor *)textErrorColor {
    UIColor *defaultColor = [UIColor redColor];
    #ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            defaultColor = [UIColor systemRedColor];
        }
    #endif
    
    return _textErrorColor ?: defaultColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = [placeholderColor copy];
    self.brandImageView.tintColor = placeholderColor;
    
    for (SPFormTextField *field in [self allFields]) {
        field.placeholderColor = _placeholderColor;
    }
}

- (UIColor *)placeholderColor {
    return _placeholderColor ?: [self.class placeholderGrayColor];
}

- (void)setNumberPlaceholder:(NSString * __nullable)numberPlaceholder {
    _numberPlaceholder = [numberPlaceholder copy];
    self.numberField.placeholder = _numberPlaceholder;
}

- (void)setExpirationPlaceholder:(NSString * __nullable)expirationPlaceholder {
    _expirationPlaceholder = [expirationPlaceholder copy];
    self.expirationField.placeholder = _expirationPlaceholder;
}

- (void)setCvcPlaceholder:(NSString * __nullable)cvcPlaceholder {
    _cvcPlaceholder = [cvcPlaceholder copy];
    self.cvcField.placeholder = _cvcPlaceholder;
}

- (void)setPostalCodePlaceholder:(NSString *)postalCodePlaceholder {
    _postalCodePlaceholder = postalCodePlaceholder.copy;
    [self updatePostalFieldPlaceholder];
}

- (void)setPostalCodeEntryEnabled:(BOOL)postalCodeEntryEnabled {
    self.viewModel.postalCodeRequired = postalCodeEntryEnabled;
    if (postalCodeEntryEnabled
        && !self.countryCode) {
        self.countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
    }
}

- (BOOL)postalCodeEntryEnabled {
    return self.viewModel.postalCodeRequired;
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

- (void)setCursorColor:(UIColor *)cursorColor {
    self.tintColor = cursorColor;
}

- (UIColor *)cursorColor {
    return self.tintColor;
}

- (void)setBorderColor:(UIColor * __nullable)borderColor {
    _borderColor = borderColor;
    if (borderColor) {
        self.layer.borderColor = [[borderColor copy] CGColor];
    } else {
        self.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (UIColor * __nullable)borderColor {
    return _borderColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return _cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return _borderWidth;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    _keyboardAppearance = keyboardAppearance;
    for (SPFormTextField *field in [self allFields]) {
        field.keyboardAppearance = keyboardAppearance;
    }
}

- (void)setInputView:(UIView *)inputView {
    _inputView = inputView;

    for (SPFormTextField *field in [self allFields]) {
        field.inputView = inputView;
    }
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    _inputAccessoryView = inputAccessoryView;
    
    for (SPFormTextField *field in [self allFields]) {
        field.inputAccessoryView = inputAccessoryView;
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

 1. If we're currently in a text field, returns the next one (ignoring postalCodeField if postalCodeEntryEnabled == NO)
 2. Otherwise, returns the first invalid field (either cycling back from the end or as it gains 1st responder)
 3. As a final fallback, just returns the last field
 */
- (nonnull SPFormTextField *)nextFirstResponderField {
    SPFormTextField *currentFirstResponder = [self currentFirstResponderField];
    if (currentFirstResponder) {
        NSUInteger index = [self.allFields indexOfObject:currentFirstResponder];
        if (index != NSNotFound) {
            SPFormTextField *nextField = [self.allFields sp_boundSafeObjectAtIndex:index + 1];
            if (nextField != nil && (self.postalCodeEntryEnabled || nextField != self.postalCodeField)) {
                return nextField;
            }
        }
    }

    return [self firstInvalidSubField] ?: [self lastSubField];
}

- (nullable SPFormTextField *)firstInvalidSubField {
    if ([self.viewModel validationStateForField:SPCardFieldTypeNumber] != SPCardValidationStateValid) {
        return self.numberField;
    } else if ([self.viewModel validationStateForField:SPCardFieldTypeExpiration] != SPCardValidationStateValid) {
        return self.expirationField;
    } else if ([self.viewModel validationStateForField:SPCardFieldTypeCVC] != SPCardValidationStateValid) {
        return self.cvcField;
    } else if (self.postalCodeEntryEnabled
             && [self.viewModel validationStateForField:SPCardFieldTypePostalCode] != SPCardValidationStateValid) {
        return self.postalCodeField;
    } else {
        return nil;
    }
}

- (nonnull SPFormTextField *)lastSubField {
    return self.postalCodeEntryEnabled ? self.postalCodeField : self.cvcField;
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
    [self layoutViewsToFocusField:nil
             becomeFirstResponder:NO
                         animated:YES
                       completion:nil];
    [self updateImageForFieldType:SPCardFieldTypeNumber];
    return success;
}

- (SPFormTextField *)previousField {
    SPFormTextField *currentSubResponder = self.currentFirstResponderField;
    if (currentSubResponder) {
        NSUInteger index = [self.allFields indexOfObject:currentSubResponder];
        if (index != NSNotFound
            && index > 0) {
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
    self.viewModel = [SPPaymentCardTextFieldViewModel new];
    [self onChange];
    [self updateImageForFieldType:SPCardFieldTypeNumber];
    [self updateCVCPlaceholder];
    __weak typeof(self) weakSelf = self;
    [self layoutViewsToFocusField:@(SPCardFieldTypePostalCode)
             becomeFirstResponder:YES
                         animated:YES
                       completion:^(__unused BOOL completed){
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf isFirstResponder]) {
            [[strongSelf numberField] becomeFirstResponder];
        }
    }];
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
    return [self.viewModel.expirationMonth stringByAppendingFormat:@"/%@", self.viewModel.expirationYear];
}

- (NSString *)cvc {
    return self.viewModel.cvc;
}

- (NSString *)postalCode {
    if (self.postalCodeEntryEnabled) {
        return self.viewModel.postalCode;
    } else {
        return nil;
    }
}

- (SPPaymentMethodCardParams *)cardParams {
    self.internalCardParams.number = self.cardNumber;
    self.internalCardParams.expMonth = @(self.expirationMonth);
    self.internalCardParams.expYear = @(self.expirationYear);
    self.internalCardParams.cvc = self.cvc;
    return [self.internalCardParams copy];
}

- (void)setCardParams:(SPPaymentMethodCardParams *)callersCardParams {
    /*
     Due to the way this class is written, programmatically setting field text
     behaves identically to user entering text (and will have the same forwarding 
     on to next responder logic).

     We have some custom logic here in the main accesible programmatic setter
     to dance around this a bit. First we save what is the current responder
     at the time this method was called. Later logic after text setting should be:
     1. If we were not first responder, we should still not be first responder
        (but layout might need updating depending on PAN validity)
     2. If original field is still not valid, it is still first responder
        (manually reset it back to first responder)
     3. Otherwise the first subfield with invalid text should now be first responder
     */
    SPFormTextField *originalSubResponder = self.currentFirstResponderField;

    /*
     #1031 small footgun hiding here. Use copies to protect from mutations of
     `internalCardParams` in the `cardParams` property accessor and any mutations
     the app code might make to their `callersCardParams` object.
     */
    SPPaymentMethodCardParams *desiredCardParams = [callersCardParams copy];
    self.internalCardParams = [desiredCardParams copy];

    [self setText:desiredCardParams.number inField:SPCardFieldTypeNumber];
    BOOL expirationPresent = desiredCardParams.expMonth && desiredCardParams.expYear;
    if (expirationPresent) {
        NSString *text = [NSString stringWithFormat:@"%02lu%02lu",
                          (unsigned long)desiredCardParams.expMonth.integerValue,
                          (unsigned long)desiredCardParams.expYear.integerValue%100];
        [self setText:text inField:SPCardFieldTypeExpiration];
    } else {
        [self setText:@"" inField:SPCardFieldTypeExpiration];
    }
    [self setText:desiredCardParams.cvc inField:SPCardFieldTypeCVC];

    if ([self isFirstResponder]) {
        SPCardFieldType fieldType = originalSubResponder.tag;
        SPCardValidationState state = [self.viewModel validationStateForField:fieldType];

        if (state == SPCardValidationStateValid) {
            SPFormTextField *nextField = [self firstInvalidSubField];
            if (nextField) {
                [nextField becomeFirstResponder];
            } else {
                [self resignFirstResponder];
            }
        } else {
            [originalSubResponder becomeFirstResponder];
        }
    } else {
        [self layoutViewsToFocusField:nil
                 becomeFirstResponder:YES
                             animated:NO
                           completion:nil];
    }

    // update the card image, falling back to the number field image if not editing
    if ([self.expirationField isFirstResponder]) {
        [self updateImageForFieldType:SPCardFieldTypeExpiration];
    } else if ([self.cvcField isFirstResponder]) {
        [self updateImageForFieldType:SPCardFieldTypeCVC];
    } else {
        [self updateImageForFieldType:SPCardFieldTypeNumber];
    }
    [self updateCVCPlaceholder];
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

- (CGFloat)numberFieldFullWidth {
    // Current longest possible pan is 16 digits which our standard sample fits
    if ([self.viewModel validationStateForField:SPCardFieldTypeNumber] == SPCardValidationStateValid) {
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
    NSArray<NSNumber *> *sortedCardNumberFormat = [[SPCardValidator cardNumberFormatForBrand:currentBrand] sortedArrayUsingSelector:@selector(unsignedIntegerValue)];
    NSUInteger fragmentLength = [SPCardValidator fragmentLengthForCardBrand:currentBrand];
    NSUInteger maxLength = MAX([[sortedCardNumberFormat lastObject] unsignedIntegerValue], fragmentLength);

    NSString *maxCompressedString = [@"" stringByPaddingToLength:maxLength withString:@"8" startingAtIndex:0];
    return [self widthForText:maxCompressedString];
}

- (CGFloat)cvcFieldWidth {
    if (self.focusedTextFieldForLayout == nil
        && [self.viewModel validationStateForField:SPCardFieldTypeCVC] == SPCardValidationStateValid) {
        // If we're not focused and have valid text, size exactly to what is entered
        return [self widthForText:self.viewModel.cvc];
    } else {
        // Otherwise size to fit our placeholder or what is likely to be the
        // largest possible string enterable (whichever is larger)
        NSInteger maxCvcLength = [SPCardValidator maxCVCLengthForCardBrand:self.viewModel.brand];
        NSString *longestCvc = @"888";
        if (maxCvcLength == 4) {
            longestCvc = @"8888";
        }

        return MAX([self widthForText:self.cvcField.placeholder], [self widthForText:longestCvc]);
    }
}

- (CGFloat)expirationFieldWidth {
    if (self.focusedTextFieldForLayout == nil
        && [self.viewModel validationStateForField:SPCardFieldTypeExpiration] == SPCardValidationStateValid) {
        // If we're not focused and have valid text, size exactly to what is entered
        return [self widthForText:self.viewModel.rawExpiration];
    } else {
        // Otherwise size to fit our placeholder or what is likely to be the
        // largest possible string enterable (whichever is larger)
        return MAX([self widthForText:self.expirationField.placeholder], [self widthForText:@"88/88"]);
    }
}

- (CGFloat)postalCodeFieldFullWidth {
    CGFloat compressedWidth = [self postalCodeFieldCompressedWidth];
    CGFloat currentTextWidth = [self widthForText:self.viewModel.postalCode];

    if (currentTextWidth <= compressedWidth) {
        return compressedWidth;
    } else if ([self.countryCode.uppercaseString isEqualToString:@"US"]) {
        // This format matches ZIP+4 which is currently disabled since it is
        // not used for billing, but could be useful for future shipping addr purposes
        return [self widthForText:@"88888-8888"];
    } else {
        // This format more closely matches the typical max UK/Canadian size which is our most common non-US market currently
        return [self widthForText:@"888 8888"];
    }
}

- (CGFloat)postalCodeFieldCompressedWidth {
    CGFloat maxTextWidth = 0;
    if ([self.countryCode.uppercaseString isEqualToString:@"US"]) {
        maxTextWidth = [self widthForText:@"88888"];
    } else {
        // This format more closely matches the typical max UK/Canadian size which is our most common non-US market currently
        maxTextWidth = [self widthForText:@"888 8888"];
    }

    CGFloat placeholderWidth = [self widthForText:[self defaultPostalFieldPlaceholderForCountryCode:self.countryCode]];
    return MAX(maxTextWidth, placeholderWidth);
}

- (CGSize)intrinsicContentSize {

    CGSize imageSize = self.brandImage.size;

    self.sizingField.text = self.viewModel.defaultPlaceholder;
    [self.sizingField sizeToFit];
    CGFloat textHeight = CGRectGetHeight(self.sizingField.frame);
    CGFloat imageHeight = imageSize.height + (SPPaymentCardTextFieldDefaultInsets);
    CGFloat height = sp_ceilCGFloat((MAX(MAX(imageHeight, textHeight), 44)));

    CGFloat width = (SPPaymentCardTextFieldDefaultInsets
                     + imageSize.width
                     + SPPaymentCardTextFieldDefaultInsets
                     + [self numberFieldFullWidth]
                     + SPPaymentCardTextFieldDefaultInsets
                     );

    width = sp_ceilCGFloat(width);

    return CGSizeMake(width, height);
}

typedef NS_ENUM(NSInteger, SPCardTextFieldState) {
    SPCardTextFieldStateVisible,
    SPCardTextFieldStateCompressed,
    SPCardTextFieldStateHidden,
};

- (CGFloat)minimumPaddingForViewsWithWidth:(CGFloat)width
                                       pan:(SPCardTextFieldState)panVisibility
                                    expiry:(SPCardTextFieldState)expiryVisibility
                                       cvc:(SPCardTextFieldState)cvcVisibility
                                    postal:(SPCardTextFieldState)postalVisibility {

    CGFloat requiredWidth = 0;
    CGFloat paddingsRequired = -1;

    if (panVisibility != SPCardTextFieldStateHidden) {
        paddingsRequired += 1;
        requiredWidth += (panVisibility == SPCardTextFieldStateCompressed) ? [self numberFieldCompressedWidth] : [self numberFieldFullWidth];
    }

    if (expiryVisibility != SPCardTextFieldStateHidden) {
        paddingsRequired += 1;
        requiredWidth += [self expirationFieldWidth];
    }

    if (cvcVisibility != SPCardTextFieldStateHidden) {
        paddingsRequired += 1;
        requiredWidth += [self cvcFieldWidth];
    }

    if (postalVisibility != SPCardTextFieldStateHidden
        && self.postalCodeEntryEnabled) {
        paddingsRequired += 1;
        requiredWidth += (postalVisibility == SPCardTextFieldStateCompressed) ? [self postalCodeFieldCompressedWidth] : [self postalCodeFieldFullWidth];
    }

    if (paddingsRequired > 0) {
        return sp_ceilCGFloat(((width - requiredWidth) / paddingsRequired));
    } else {
        return SPPaymentCardTextFieldMinimumPadding;
    }
}

- (CGRect)brandImageRectForBounds:(CGRect)bounds {
    return CGRectMake(SPPaymentCardTextFieldDefaultPadding, -1, self.brandImageView.image.size.width, bounds.size.height);
}

- (CGRect)fieldsRectForBounds:(CGRect)bounds {
    CGRect brandImageRect = [self brandImageRectForBounds:bounds];
    return CGRectMake(CGRectGetMaxX(brandImageRect), 0, CGRectGetWidth(bounds) - CGRectGetMaxX(brandImageRect), CGRectGetHeight(bounds));
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

    CGFloat availableFieldsWidth = CGRectGetWidth(fieldsViewRect) - (2 * SPPaymentCardTextFieldDefaultInsets);

    // These values are filled in via the if statements and then used
    // to do the proper layout at the end
    CGFloat fieldsHeight = CGRectGetHeight(fieldsViewRect);
    CGFloat hPadding = SPPaymentCardTextFieldDefaultPadding;
    __block SPCardTextFieldState panVisibility = SPCardTextFieldStateVisible;
    __block SPCardTextFieldState expiryVisibility = SPCardTextFieldStateVisible;
    __block SPCardTextFieldState cvcVisibility = SPCardTextFieldStateVisible;
    __block SPCardTextFieldState postalVisibility = self.postalCodeEntryEnabled ? SPCardTextFieldStateVisible : SPCardTextFieldStateHidden;

    CGFloat (^calculateMinimumPaddingWithLocalVars)(void) = ^CGFloat() {
        return [self minimumPaddingForViewsWithWidth:availableFieldsWidth
                                                 pan:panVisibility
                                              expiry:expiryVisibility
                                                 cvc:cvcVisibility
                                              postal:postalVisibility];
    };

    hPadding = calculateMinimumPaddingWithLocalVars();

    if (hPadding >= SPPaymentCardTextFieldMinimumPadding) {
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
            while (hPadding < SPPaymentCardTextFieldMinimumPadding) {
                // Try hiding things in this order
                if (panVisibility == SPCardTextFieldStateVisible) {
                    panVisibility = SPCardTextFieldStateCompressed;
                } else if (postalVisibility == SPCardTextFieldStateVisible) {
                    postalVisibility = SPCardTextFieldStateCompressed;
                } else {
                    // Can't hide anything else, set to minimum and stop
                    hPadding = SPPaymentCardTextFieldMinimumPadding;
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

                    while (hPadding < SPPaymentCardTextFieldMinimumPadding) {
                        if (postalVisibility == SPCardTextFieldStateVisible) {
                            postalVisibility = SPCardTextFieldStateCompressed;
                        } else if (postalVisibility == SPCardTextFieldStateCompressed) {
                            postalVisibility = SPCardTextFieldStateHidden;
                        } else if (cvcVisibility == SPCardTextFieldStateVisible) {
                            cvcVisibility = SPCardTextFieldStateHidden;
                        } else if (expiryVisibility == SPCardTextFieldStateVisible) {
                            expiryVisibility = SPCardTextFieldStateHidden;
                        } else {
                            hPadding = SPPaymentCardTextFieldMinimumPadding;
                            break;
                        }
                        hPadding = calculateMinimumPaddingWithLocalVars();
                    }
                }
                    break;
                case SPCardFieldTypeExpiration: {
                    /*
                     The user is entering expiration date

                     It must be fully visible, and the next and previous fields
                     must be visible so they can be tapped over to
                     */
                    while (hPadding < SPPaymentCardTextFieldMinimumPadding) {
                        if (panVisibility == SPCardTextFieldStateVisible) {
                            panVisibility = SPCardTextFieldStateCompressed;
                        } else if (postalVisibility == SPCardTextFieldStateVisible) {
                            postalVisibility = SPCardTextFieldStateCompressed;
                        } else if (postalVisibility == SPCardTextFieldStateCompressed) {
                            postalVisibility = SPCardTextFieldStateHidden;
                        } else {
                            hPadding = SPPaymentCardTextFieldMinimumPadding;
                            break;
                        }
                        hPadding = calculateMinimumPaddingWithLocalVars();
                    }
                }
                    break;

                case SPCardFieldTypeCVC: {
                    /*
                     The user is entering CVC

                     It must be fully visible, and the next and previous fields
                     must be visible so they can be tapped over to (although
                     there might not be a next field)
                     */
                    while (hPadding < SPPaymentCardTextFieldMinimumPadding) {
                        if (panVisibility == SPCardTextFieldStateVisible) {
                            panVisibility = SPCardTextFieldStateCompressed;
                        } else if (postalVisibility == SPCardTextFieldStateVisible) {
                            postalVisibility = SPCardTextFieldStateCompressed;
                        } else if (panVisibility == SPCardTextFieldStateCompressed) {
                            panVisibility = SPCardTextFieldStateHidden;
                        } else {
                            hPadding = SPPaymentCardTextFieldMinimumPadding;
                            break;
                        }
                        hPadding = calculateMinimumPaddingWithLocalVars();
                    }
                }
                    break;
                case SPCardFieldTypePostalCode: {
                    /*
                     The user is entering postal code

                     It must be fully visible, and the previous field must
                     be visible
                     */
                    while (hPadding < SPPaymentCardTextFieldMinimumPadding) {
                        if (panVisibility == SPCardTextFieldStateVisible) {
                            panVisibility = SPCardTextFieldStateCompressed;
                        } else if (panVisibility == SPCardTextFieldStateCompressed) {
                            panVisibility = SPCardTextFieldStateHidden;
                        } else if (expiryVisibility == SPCardTextFieldStateVisible) {
                            expiryVisibility = SPCardTextFieldStateHidden;
                        } else {
                            hPadding = SPPaymentCardTextFieldMinimumPadding;
                            break;
                        }
                        hPadding = calculateMinimumPaddingWithLocalVars();
                    }
                }
                    break;
            }
        }
    }

    // -- Do layout here --
    CGFloat xOffset = SPPaymentCardTextFieldDefaultInsets;
    CGFloat width = 0;

    // Make all fields actually slightly wider than needed so that when the
    // cursor is at the end position the contents aren't clipped off to the left side
    CGFloat additionalWidth = [self widthForText:@"8"];

    if (panVisibility == SPCardTextFieldStateCompressed) {
        // Need to lower xOffset so pan is partially off-screen

        BOOL hasEnteredCardNumber = self.cardNumber.length > 0;
        NSString *compressedCardNumber = self.viewModel.compressedCardNumber;
        NSString *cardNumberToHide = [(hasEnteredCardNumber ? self.cardNumber : self.numberPlaceholder) sp_stringByRemovingSuffix:compressedCardNumber];

        if (cardNumberToHide.length > 0 && [SPCardValidator stringIsNumeric:cardNumberToHide]) {
            width = hasEnteredCardNumber ? [self widthForCardNumber:self.cardNumber] : [self numberFieldFullWidth];

            CGFloat hiddenWidth = [self widthForCardNumber:cardNumberToHide];
            xOffset -= hiddenWidth;
            UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(hiddenWidth,
                                                                        0,
                                                                        (width - hiddenWidth),
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

        if (panVisibility == SPCardTextFieldStateHidden) {
            // Need to lower xOffset so pan is fully off screen
            xOffset = xOffset - width - hPadding;
        }
    }

    self.numberField.frame = CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
    xOffset += width + hPadding;

    width = [self expirationFieldWidth];
    self.expirationField.frame = CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
    xOffset += width + hPadding;

    width = [self cvcFieldWidth];
    self.cvcField.frame = CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
    xOffset += width + hPadding;

    if (self.postalCodeEntryEnabled) {
        width = self.fieldsView.frame.size.width - xOffset - SPPaymentCardTextFieldDefaultInsets;
        self.postalCodeField.frame = CGRectMake(xOffset, 0, width + additionalWidth, fieldsHeight);
    }

    void (^updateFieldVisibility)(SPFormTextField *, SPCardTextFieldState) = ^(SPFormTextField *field, SPCardTextFieldState fieldState) {
        if (fieldState == SPCardTextFieldStateHidden) {
            field.alpha = 0.0f;
            field.isAccessibilityElement = NO;
        } else {
            field.alpha = 1.0f;
            field.isAccessibilityElement = YES;
        }
    };

    updateFieldVisibility(self.numberField, panVisibility);
    updateFieldVisibility(self.expirationField, expiryVisibility);
    updateFieldVisibility(self.cvcField, cvcVisibility);
    updateFieldVisibility(self.postalCodeField, self.postalCodeEntryEnabled ? postalVisibility :  SPCardTextFieldStateHidden);
}

#pragma mark - private helper methods

- (SPFormTextField *)buildTextField {
    SPFormTextField *textField = [[SPFormTextField alloc] initWithFrame:CGRectZero];
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

typedef void (^SPLayoutAnimationCompletionBlock)(BOOL completed);
- (void)layoutViewsToFocusField:(NSNumber *)focusedField
           becomeFirstResponder:(BOOL)shouldBecomeFirstResponder
                       animated:(BOOL)animated
                     completion:(SPLayoutAnimationCompletionBlock)completion {

    NSNumber *fieldtoFocus = focusedField;

    if (fieldtoFocus == nil
        && ![self.focusedTextFieldForLayout isEqualToNumber:@(SPCardFieldTypeNumber)]
        && ([self.viewModel validationStateForField:SPCardFieldTypeNumber] != SPCardValidationStateValid)) {
        fieldtoFocus = @(SPCardFieldTypeNumber);
        if (shouldBecomeFirstResponder) {
            [self.numberField becomeFirstResponder];
        }
    }

    if ((fieldtoFocus == nil && self.focusedTextFieldForLayout == nil)
        || (fieldtoFocus != nil && [self.focusedTextFieldForLayout isEqualToNumber:fieldtoFocus])
        ) {
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
        self.sizingField.autoFormattingBehavior = SPFormTextFieldAutoFormattingBehaviorNone;
        [self.sizingField setText:text];
        cachedValue = @([self widthForAttributedText:self.sizingField.attributedText]);
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
        self.sizingField.autoFormattingBehavior = SPFormTextFieldAutoFormattingBehaviorCardNumbers;
        [self.sizingField setText:cardNumber];
        cachedValue = @([self widthForAttributedText:self.sizingField.attributedText]);
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
            return [[NSAttributedString alloc] initWithString:self.viewModel.cardNumber
                                                   attributes:self.numberField.defaultTextAttributes];
        case SPCardFieldTypeExpiration:
            return [[NSAttributedString alloc] initWithString:self.viewModel.rawExpiration
                                                   attributes:self.expirationField.defaultTextAttributes];
        case SPCardFieldTypeCVC:
            return [[NSAttributedString alloc] initWithString:self.viewModel.cvc
                                                   attributes:self.cvcField.defaultTextAttributes];
        case SPCardFieldTypePostalCode:
            return [[NSAttributedString alloc] initWithString:self.viewModel.postalCode
                                                   attributes:self.cvcField.defaultTextAttributes];
    }
}

- (void)formTextFieldTextDidChange:(SPFormTextField *)formTextField {
    SPCardFieldType fieldType = formTextField.tag;
    if (fieldType == SPCardFieldTypeNumber) {
        [self updateImageForFieldType:fieldType];
        [self updateCVCPlaceholder];
        // Changing the card number field can invalidate the cvc, e.g. going from 4 digit Amex cvc to 3 digit Visa
        self.cvcField.validText = [self.viewModel validationStateForField:SPCardFieldTypeCVC] != SPCardValidationStateInvalid;
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

typedef NS_ENUM(NSInteger, SPFieldEditingTransitionCallSite) {
    SPFieldEditingTransitionCallSiteShouldBegin,
    SPFieldEditingTransitionCallSiteShouldEnd,
    SPFieldEditingTransitionCallSiteDidBegin,
    SPFieldEditingTransitionCallSiteDidEnd,
};

// Explanation of the logic here is with the definition of these properties
// at the top of this file
- (BOOL)getAndUpdateSubviewEditingTransitionStateFromCall:(SPFieldEditingTransitionCallSite)sendingMethod {
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


- (void)resetSubviewEditingTransitionState {
    self.isMidSubviewEditingTransitionInternal = NO;
    self.receivedUnmatchedShouldBeginEditing = NO;
    self.receivedUnmatchedShouldEndEditing = NO;
}

- (BOOL)textFieldShouldBeginEditing:(__unused UITextField *)textField {
    [self getAndUpdateSubviewEditingTransitionStateFromCall:SPFieldEditingTransitionCallSiteShouldBegin];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    BOOL isMidSubviewEditingTransition = [self getAndUpdateSubviewEditingTransitionStateFromCall:SPFieldEditingTransitionCallSiteDidBegin];

    [self layoutViewsToFocusField:@(textField.tag)
             becomeFirstResponder:YES
                         animated:YES
                       completion:nil];

    if (!isMidSubviewEditingTransition) {
        if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidBeginEditing:)]) {
            [self.delegate paymentCardTextFieldDidBeginEditing:self];
        }
    }

    switch ((SPCardFieldType)textField.tag) {
        case SPCardFieldTypeNumber:
            ((SPFormTextField *)textField).validText = YES;
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidBeginEditingNumber:)]) {
                [self.delegate paymentCardTextFieldDidBeginEditingNumber:self];
            }
            break;
        case SPCardFieldTypeCVC:
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidBeginEditingCVC:)]) {
                [self.delegate paymentCardTextFieldDidBeginEditingCVC:self];
            }
            break;
        case SPCardFieldTypeExpiration:
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidBeginEditingExpiration:)]) {
                [self.delegate paymentCardTextFieldDidBeginEditingExpiration:self];
            }
            break;
        case SPCardFieldTypePostalCode:
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidBeginEditingPostalCode:)]) {
                [self.delegate paymentCardTextFieldDidBeginEditingPostalCode:self];
            }
            break;
    }
    [self updateImageForFieldType:textField.tag];
}

- (BOOL)textFieldShouldEndEditing:(__unused UITextField *)textField {
    [self getAndUpdateSubviewEditingTransitionStateFromCall:SPFieldEditingTransitionCallSiteShouldEnd];
    [self updateImageForFieldType:SPCardFieldTypeNumber];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOOL isMidSubviewEditingTransition = [self getAndUpdateSubviewEditingTransitionStateFromCall:SPFieldEditingTransitionCallSiteDidEnd];

    switch ((SPCardFieldType)textField.tag) {
        case SPCardFieldTypeNumber:
            if ([self.viewModel validationStateForField:SPCardFieldTypeNumber] == SPCardValidationStateIncomplete) {
                ((SPFormTextField *)textField).validText = NO;
            }
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidEndEditingNumber:)]) {
                [self.delegate paymentCardTextFieldDidEndEditingNumber:self];
            }
            break;
        case SPCardFieldTypeCVC:
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidEndEditingCVC:)]) {
                [self.delegate paymentCardTextFieldDidEndEditingCVC:self];
            }
            break;
        case SPCardFieldTypeExpiration:
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidEndEditingExpiration:)]) {
                [self.delegate paymentCardTextFieldDidEndEditingExpiration:self];
            }
            break;
        case SPCardFieldTypePostalCode:
            if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidEndEditingPostalCode:)]) {
                [self.delegate paymentCardTextFieldDidEndEditingPostalCode:self];
            }
            break;
    }

    if (!isMidSubviewEditingTransition) {
        [self layoutViewsToFocusField:nil
                 becomeFirstResponder:NO
                             animated:YES
                           completion:nil];
        [self updateImageForFieldType:SPCardFieldTypeNumber];
        if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidEndEditing:)]) {
            [self.delegate paymentCardTextFieldDidEndEditing:self];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self lastSubField] && [self firstInvalidSubField] == nil) {
        // User pressed return in the last field, and all fields are valid
        if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldWillEndEditingForReturn:)]) {
            [self.delegate paymentCardTextFieldWillEndEditingForReturn:self];
        }
        [self resignFirstResponder];
    } else {
        // otherwise, move to the next field
        [[self nextFirstResponderField] becomeFirstResponder];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    }

    return NO;
}

- (UIImage *)brandImage {
    SPCardFieldType fieldType = SPCardFieldTypeNumber;
    if (self.currentFirstResponderField) {
        fieldType = self.currentFirstResponderField.tag;
    }
    SPCardValidationState validationState = [self.viewModel validationStateForField:fieldType];
    return [self brandImageForFieldType:fieldType validationState:validationState];
}

+ (UIImage *)cvcImageForCardBrand:(SPCardBrand)cardBrand {
    return [SPImageLibrary cvcImageForCardBrand:cardBrand];
}

+ (UIImage *)brandImageForCardBrand:(SPCardBrand)cardBrand {
    return [SPImageLibrary brandImageForCardBrand:cardBrand];
}

+ (UIImage *)errorImageForCardBrand:(SPCardBrand)cardBrand {
    return [SPImageLibrary errorImageForCardBrand:cardBrand];
}

- (UIImage *)brandImageForFieldType:(SPCardFieldType)fieldType validationState:(SPCardValidationState)validationState {
    switch (fieldType) {
        case SPCardFieldTypeNumber:
            if (validationState == SPCardValidationStateInvalid) {
                return [self.class errorImageForCardBrand:self.viewModel.brand];
            } else {
                return [self.class brandImageForCardBrand:self.viewModel.brand];
            }
        case SPCardFieldTypeCVC:
            return [self.class cvcImageForCardBrand:self.viewModel.brand];
        case SPCardFieldTypeExpiration:
            return [self.class brandImageForCardBrand:self.viewModel.brand];
        case SPCardFieldTypePostalCode:
            return [self.class brandImageForCardBrand:self.viewModel.brand];
    }
}

- (UIViewAnimationOptions)brandImageAnimationOptionsForNewType:(SPCardFieldType)newType
                                                      newBrand:(SPCardBrand)newBrand
                                                       oldType:(SPCardFieldType)oldType
                                                      oldBrand:(SPCardBrand)oldBrand {

    if (newType == SPCardFieldTypeCVC
        && oldType != SPCardFieldTypeCVC) {
        // Transitioning to show CVC

        if (newBrand != SPCardBrandAmex) {
            // CVC is on the back
            return (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionFlipFromRight);
        }
    } else if (newType != SPCardFieldTypeCVC
             && oldType == SPCardFieldTypeCVC) {
        // Transitioning to stop showing CVC

        if (oldBrand != SPCardBrandAmex) {
            // CVC was on the back
            return (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionFlipFromLeft);
        }
    }

    // All other cases just cross dissolve
    return (UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve);

}

- (void)updateImageForFieldType:(SPCardFieldType)fieldType {
    SPCardValidationState validationState = [self.viewModel validationStateForField:fieldType];
    UIImage *image = [self brandImageForFieldType:fieldType validationState:validationState];
    if (![image isEqual:self.brandImageView.image]) {

        SPCardBrand newBrand = self.viewModel.brand;
        UIViewAnimationOptions imageAnimationOptions = [self brandImageAnimationOptionsForNewType:fieldType
                                                                                         newBrand:newBrand
                                                                                          oldType:self.currentBrandImageFieldType
                                                                                         oldBrand:self.currentBrandImageBrand];

        self.currentBrandImageFieldType = fieldType;
        self.currentBrandImageBrand = newBrand;

        [UIView transitionWithView:self.brandImageView
                          duration:0.2
                           options:imageAnimationOptions
                        animations:^{
                            self.brandImageView.image = image;
                        }
                        completion:nil];
    }
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
    if ([self.delegate respondsToSelector:@selector(paymentCardTextFieldDidChange:)]) {
        [self.delegate paymentCardTextFieldDidChange:self];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark UIKeyInput

- (BOOL)hasText {
    return self.numberField.hasText || self.expirationField.hasText || self.cvcField.hasText;
}

- (void)insertText:(NSString *)text {
    [self.currentFirstResponderField insertText:text];
}

- (void)deleteBackward {
    [self.currentFirstResponderField deleteBackward];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsValid {
    return [NSSet setWithArray:@[
                                 [NSString stringWithFormat:@"%@.%@",
                                  NSStringFromSelector(@selector(viewModel)),
                                  NSStringFromSelector(@selector(valid))],
                                 ]];
}

@end
