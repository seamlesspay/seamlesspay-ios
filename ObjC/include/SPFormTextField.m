/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPFormTextField.h"
#import "NSString+Extras.h"
#import "SPCardValidator+Extras.h"
#import "SPCardValidator.h"
#import "SPDelegateProxy.h"
#import "SPPhoneNumberValidator.h"

@interface SPTextFieldDelegateProxy : SPDelegateProxy <UITextFieldDelegate>

@property(nonatomic, assign) SPFormTextFieldAutoFormattingBehavior autoformattingBehavior;
@property(nonatomic, assign) BOOL selectionEnabled;

@end

@implementation SPTextFieldDelegateProxy

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
  BOOL insertingIntoEmptyField =
  (textField.text.length == 0 && range.location == 0 && range.length == 0);
  BOOL hasTextContentType = textField.textContentType != nil;

  if (hasTextContentType && insertingIntoEmptyField &&
      [string isEqualToString:@" "]) {
    /* Observed behavior w/iOS 11.0 through 11.2.0 (latest):

     1. UITextContentType suggestions are only available when textField is empty
     2. When user taps a QuickType suggestion for the `textContentType`, UIKit
     *first* calls this method with `range:{0, 0} replacementString:@" "`
     3. If that succeeds (we return YES), this method is called again, this time
     with the actual content to insert (and a space at the end)

     Therefore, always allow entry of a single space in order to support
     `textContentType`.

     Warning: This bypasses `setText:`, and subsequently `setAttributedText:`
     and the formDelegate methods: `formTextField:modifyIncomingTextChange:` &
     `formTextFieldTextDidChange:` That's acceptable for a single space.
     */
    return YES;
  }

  BOOL deleting = (range.location == textField.text.length - 1 &&
                   range.length == 1 && [string isEqualToString:@""]);
  NSString *inputText;
  if (deleting) {
    NSString *sanitized = [self unformattedStringForString:textField.text];
    inputText = [sanitized sp_safeSubstringToIndex:sanitized.length - 1];
  } else {
    NSString *newString =
    [textField.text stringByReplacingCharactersInRange:range
                                            withString:string];
    // Removes any disallowed characters from the whole string.
    // If we (incorrectly) allowed a space to start the text entry hoping it
    // would be a textContentType completion, this will remove it.
    NSString *sanitized = [self unformattedStringForString:newString];
    inputText = sanitized;
  }

  UITextPosition *beginning = textField.beginningOfDocument;
  UITextPosition *start = [textField positionFromPosition:beginning
                                                   offset:range.location];

  if ([textField.text isEqualToString:inputText]) {
    return NO;
  }

  textField.text = inputText;

  if (self.autoformattingBehavior ==
      SPFormTextFieldAutoFormattingBehaviorNone &&
      self.selectionEnabled) {

    // this will be the new cursor location after insert/paste/typing
    NSInteger cursorOffset = [textField offsetFromPosition:beginning
                                                toPosition:start] +
    string.length;

    UITextPosition *newCursorPosition =
    [textField positionFromPosition:textField.beginningOfDocument
                             offset:cursorOffset];
    UITextRange *newSelectedRange =
    [textField textRangeFromPosition:newCursorPosition
                          toPosition:newCursorPosition];
    [textField setSelectedTextRange:newSelectedRange];
  }

  return NO;
}

- (NSString *)unformattedStringForString:(NSString *)string {
  switch (self.autoformattingBehavior) {
    case SPFormTextFieldAutoFormattingBehaviorNone:
      return string;
    case SPFormTextFieldAutoFormattingBehaviorCardNumbers:
    case SPFormTextFieldAutoFormattingBehaviorPhoneNumbers:
    case SPFormTextFieldAutoFormattingBehaviorExpiration:
      return [SPCardValidator sanitizedNumericStringForString:string];
  }
}

@end

typedef NSAttributedString * (^SPFormTextTransformationBlock)(
                                                              NSAttributedString *inputText);

@interface SPFormTextField ()
@property(nonatomic) SPTextFieldDelegateProxy *delegateProxy;
@property(nonatomic, copy) SPFormTextTransformationBlock textFormattingBlock;
@end

@implementation SPFormTextField

+ (NSDictionary *)attributesForAttributedString:
(NSAttributedString *)attributedString {
  if (attributedString.length == 0) {
    return @{};
  }
  return [attributedString
          attributesAtIndex:0
          longestEffectiveRange:nil
          inRange:NSMakeRange(0, attributedString.length)];
}

- (void)setSelectionEnabled:(BOOL)selectionEnabled {
  _selectionEnabled = selectionEnabled;
  self.delegateProxy.selectionEnabled = selectionEnabled;
}

- (void)setAutoFormattingBehavior:(SPFormTextFieldAutoFormattingBehavior)autoFormattingBehavior {

  _autoFormattingBehavior = autoFormattingBehavior;
  self.delegateProxy.autoformattingBehavior = autoFormattingBehavior;
  switch (autoFormattingBehavior) {
    case SPFormTextFieldAutoFormattingBehaviorNone:
    case SPFormTextFieldAutoFormattingBehaviorExpiration:
      self.textFormattingBlock = nil;
      break;
    case SPFormTextFieldAutoFormattingBehaviorCardNumbers:
      self.textFormattingBlock =
      ^NSAttributedString *(NSAttributedString *inputString) {
        if (![SPCardValidator stringIsNumeric:inputString.string]) {
          return [inputString copy];
        }
        NSMutableAttributedString *attributedString = [inputString mutableCopy];
        SPCardBrand currentBrand =
        [SPCardValidator brandForNumber:attributedString.string];
        NSArray<NSNumber *> *cardNumberFormat =
        [SPCardValidator cardNumberFormatForBrand:currentBrand];

        NSUInteger index = 0;
        for (NSNumber *segmentLength in cardNumberFormat) {
          NSUInteger segmentIndex = 0;
          for (; index < attributedString.length &&
               segmentIndex < [segmentLength unsignedIntegerValue];
               index++, segmentIndex++) {
            if (index + 1 != attributedString.length &&
                segmentIndex + 1 == [segmentLength unsignedIntegerValue]) {
              [attributedString addAttribute:NSKernAttributeName
                                       value:@(5)
                                       range:NSMakeRange(index, 1)];
            } else {
              [attributedString addAttribute:NSKernAttributeName
                                       value:@(0)
                                       range:NSMakeRange(index, 1)];
            }
          }
        }
        return [attributedString copy];
      };
      break;
    case SPFormTextFieldAutoFormattingBehaviorPhoneNumbers: {
      __weak typeof(self) weakSelf = self;
      self.textFormattingBlock =
      ^NSAttributedString *(NSAttributedString *inputString) {
        if (![SPCardValidator stringIsNumeric:inputString.string]) {
          return [inputString copy];
        }
        __strong typeof(self) strongSelf = weakSelf;
        NSString *phoneNumber = [SPPhoneNumberValidator
                                 formattedSanitizedPhoneNumberForString:inputString.string];
        NSDictionary *attributes =
        [[strongSelf class] attributesForAttributedString:inputString];
        return [[NSAttributedString alloc] initWithString:phoneNumber
                                               attributes:attributes];
      };
      break;
    }
  }
}

- (void)setFormDelegate:(id<SPFormTextFieldDelegate>)formDelegate {
  _formDelegate = formDelegate;
  self.delegate = formDelegate;
}

- (void)insertText:(NSString *)text {
  [self setText:[self.text stringByAppendingString:text]];
}

- (void)deleteBackward {
  [super deleteBackward];
  if (self.text.length == 0) {
    if ([self.formDelegate
         respondsToSelector:@selector(formTextFieldDidBackspaceOnEmpty:)]) {
      [self.formDelegate formTextFieldDidBackspaceOnEmpty:self];
    }
  }
}

- (void)setText:(NSString *)text {
  NSString *nonNilText = text ?: @"";
  NSAttributedString *attributed =
  [[NSAttributedString alloc] initWithString:nonNilText
                                  attributes:self.defaultTextAttributes];
  [self setAttributedText:attributed];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
  NSAttributedString *oldValue = [self attributedText];
  BOOL shouldModify =
  self.formDelegate &&
  [self.formDelegate respondsToSelector:@selector(formTextField:
                                                  modifyIncomingTextChange:)];
  NSAttributedString *modified =
  shouldModify ? [self.formDelegate formTextField:self
                         modifyIncomingTextChange:attributedText]
  : attributedText;
  NSAttributedString *transformed =
  self.textFormattingBlock ? self.textFormattingBlock(modified) : modified;
  [super setAttributedText:transformed];
  [self sendActionsForControlEvents:UIControlEventEditingChanged];
  if ([self.formDelegate
       respondsToSelector:@selector(formTextFieldTextDidChange:)]) {
    if (![transformed isEqualToAttributedString:oldValue]) {
      [self.formDelegate formTextFieldTextDidChange:self];
    }
  }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
// accessibilityAttributedValue is only defined on iOS 11 and up, but we
// implement it immediately below, so we should just ignore the warning.
- (NSString *)accessibilityValue {
  return [[self accessibilityAttributedValue] string];
}
#pragma clang diagnostic pop

- (NSAttributedString *)accessibilityAttributedValue {
  NSMutableAttributedString *attributedString =
  [self.attributedText mutableCopy];
  [attributedString addAttribute:UIAccessibilitySpeechAttributeSpellOut
                           value:@(YES)
                           range:NSMakeRange(0, [attributedString length])];
  if (!self.validText) {
    NSString *invalidData = @"Invalid data.";
    NSMutableAttributedString *failedString = [[NSMutableAttributedString alloc]
                                               initWithString:invalidData
                                               attributes:@{UIAccessibilitySpeechAttributePitch : @(0.6)}];
    [failedString appendAttributedString:attributedString];
    attributedString = failedString;
  }
  return attributedString;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
  NSAttributedString *transformed =
  self.textFormattingBlock ? self.textFormattingBlock(attributedPlaceholder)
  : attributedPlaceholder;
  [super setAttributedPlaceholder:transformed];
}

// Fixes a weird issue related to our custom override of deleteBackwards. This
// only affects the simulator and iPads with custom keyboards.
- (NSArray *)keyCommands {
  return
  @[ [UIKeyCommand keyCommandWithInput:@"\b"
                         modifierFlags:UIKeyModifierCommand
                                action:@selector(commandDeleteBackwards)] ];
}

- (void)commandDeleteBackwards {
  self.text = @"";
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point {
  if (self.selectionEnabled) {
    return [super closestPositionToPoint:point];
  }
  return [self positionFromPosition:self.beginningOfDocument
                             offset:self.text.length];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  return [super canPerformAction:action withSender:sender] &&
  action == @selector(paste:);
}

- (void)paste:(id)sender {
  if (self.preservesContentsOnPaste) {
    [super paste:sender];
  } else {
    self.text = [UIPasteboard generalPasteboard].string;
  }
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  SPTextFieldDelegateProxy *delegateProxy =
  [[SPTextFieldDelegateProxy alloc] init];
  delegateProxy.autoformattingBehavior = self.autoFormattingBehavior;
  delegateProxy.selectionEnabled = self.selectionEnabled;
  delegateProxy.delegate = delegate;
  self.delegateProxy = delegateProxy;
  [super setDelegate:delegateProxy];
}

- (id<UITextFieldDelegate>)delegate {
  return self.delegateProxy;
}

@end
