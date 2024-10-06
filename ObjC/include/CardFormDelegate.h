/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "CardForm.h"

@protocol CardFormProtocol <NSObject>
@required

@property(nonatomic, readonly) BOOL isValid;

@end

/**
 This protocol allows a delegate to be notified when a payment text field's
 contents change, which can in turn be used to take further actions depending
 on the validity of its contents.
 */
@protocol CardFormDelegate <NSObject>
@optional
/**
 Called when either the card number, expiration, or CVC changes. At this point,
 one can call `isValid` on the text field to determine, for example,
 whether or not to enable a button to submit the form. Example:

 - (void)cardFormDidChange:(CardForm *)view {
 self.paymentButton.enabled = view.isValid;
 }

 @param view the CardForm that has changed
 */
- (void)cardFormDidChange:(nonnull id<CardFormProtocol>)form;

/**
 Called when editing begins in the text field as a whole.

 After receiving this callback, you will always also receive a callback for
 which specific subfield of the view began editing.
 */
- (void)cardFormDidBeginEditing:(nonnull id<CardFormProtocol>)form;

/**
 Notification that the user pressed the `return` key after completely filling
 out the CardForm with data that passes validation.

 This is delivered *before* the corresponding
 `cardFormDidEndEditing:`

 @param view The CardForm that was being edited when the user
 pressed return
 */
- (void)cardFormWillEndEditingForReturn:(nonnull id<CardFormProtocol>)form;

/**
 Called when editing ends in the text field as a whole.

 This callback is always preceded by an callback for which
 specific subfield of the view ended its editing.
 */
- (void)cardFormDidEndEditing:(nonnull id<CardFormProtocol>)form;

/**
 Called when editing ends in the card field of a specific type.
 */
- (void)cardForm:(nonnull id<CardFormProtocol>)form didEndEditingField:(SPCardFieldType)field;

/**
 Called when editing begins in the card field of a specific type.
 */
- (void)cardForm:(nonnull id<CardFormProtocol>)form didBeginEditingField:(SPCardFieldType)field;

@end
