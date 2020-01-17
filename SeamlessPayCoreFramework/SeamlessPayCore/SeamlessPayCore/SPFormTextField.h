//
//  SPFormTextField.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

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
- (void)formTextFieldDidBackspaceOnEmpty:(nonnull SPFormTextField *)formTextField;
- (nonnull NSAttributedString *)formTextField:(nonnull SPFormTextField *)formTextField
           modifyIncomingTextChange:(nonnull NSAttributedString *)input;
- (void)formTextFieldTextDidChange:(nonnull SPFormTextField *)textField;
@end

@interface SPFormTextField : SPValidatedTextField

@property (nonatomic, readwrite, assign) BOOL selectionEnabled; // defaults to NO
@property (nonatomic, readwrite, assign) BOOL preservesContentsOnPaste; // defaults to NO
@property (nonatomic, readwrite, assign) SPFormTextFieldAutoFormattingBehavior autoFormattingBehavior;
@property (nonatomic, readwrite, weak, nullable) id<SPFormTextFieldDelegate>formDelegate;

@end
