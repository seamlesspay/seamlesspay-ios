/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import "SPValidatedTextField.h"

@class SPFormTextField;

typedef NS_ENUM(NSInteger, SPFormTextFieldAutoFormattingBehavior) {
  SPFormTextFieldAutoFormattingBehaviorNone,
  SPFormTextFieldAutoFormattingBehaviorPhoneNumbers,
  SPFormTextFieldAutoFormattingBehaviorCardNumbers,
  SPFormTextFieldAutoFormattingBehaviorExpiration,
};

@protocol SPFormTextFieldDelegate <UITextFieldDelegate>
@optional
- (void)formTextFieldDidBackspaceOnEmpty:
    (nonnull SPFormTextField *)formTextField;
- (nonnull NSAttributedString *)
               formTextField:(nonnull SPFormTextField *)formTextField
    modifyIncomingTextChange:(nonnull NSAttributedString *)input;
- (void)formTextFieldTextDidChange:(nonnull SPFormTextField *)textField;
@end

@interface SPFormTextField : SPValidatedTextField

@property(nonatomic, readwrite, assign) BOOL selectionEnabled; // defaults to NO
@property(nonatomic, readwrite, assign)
    BOOL preservesContentsOnPaste; // defaults to NO
@property(nonatomic, readwrite, assign)
    SPFormTextFieldAutoFormattingBehavior autoFormattingBehavior;
@property(nonatomic, readwrite, weak, nullable) id<SPFormTextFieldDelegate>
    formDelegate;

@end
