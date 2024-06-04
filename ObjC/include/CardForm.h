/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CardFieldDisplay) {
  CardFieldDisplayNone,
  CardFieldDisplayOptional,
  CardFieldDisplayRequired,
};

@class CardForm;
@protocol CardFormDelegate;

@interface CardForm : UIControl <UIKeyInput>

/**
 @see CardFormDelegate
 */
@property(nonatomic, weak, nullable) IBOutlet id<CardFormDelegate> delegate;

/**
 The curent brand image displayed in the receiver.
 */
@property(nonatomic, nullable, readonly) UIImage *brandImage;

/**
 Whether or not the form currently contains a valid card number,
 expiration date, CVC, and postal code (if required).

 @see SPCardValidator
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 Enable/disable
 */
@property(nonatomic, getter=isEnabled) BOOL enabled;

/**
 The two-letter ISO country code that corresponds to the user's billing address.

 If set to nil and postal code entry is enabled, the country from the user's
 current locale will be filled in. Otherwise the specific country code set will
 be used.

 By default this will fetch the user's current country code from NSLocale.
 */
@property(nonatomic, copy, nullable) NSString *countryCode;

/**
 Causes the text field to begin editing. Presents the keyboard.

 @return Whether or not the text field successfully began editing.
 @see UIResponder
 */
- (BOOL)becomeFirstResponder;

/**
 Causes the text field to stop editing. Dismisses the keyboard.

 @return Whether or not the field successfully stopped editing.
 @see UIResponder
 */
- (BOOL)resignFirstResponder;

/**
 Resets all of the contents of all of the fields. If the field is currently
 being edited, the number field will become selected.
 */
- (void)clear;

- (void)setCVCDisplayConfig:(CardFieldDisplay)displayConfig;
- (void)setPostalCodeDisplayConfig:(CardFieldDisplay)displayConfig;

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
- (void)cardFormDidChange:(nonnull CardForm *)view;

/**
 Called when editing begins in the text field as a whole.

 After receiving this callback, you will always also receive a callback for
 which specific subfield of the view began editing.
 */
- (void)cardFormDidBeginEditing:(nonnull CardForm *)view;

/**
 Notification that the user pressed the `return` key after completely filling
 out the CardForm with data that passes validation.

 This is delivered *before* the corresponding
 `cardFormDidEndEditing:`

 @param view The CardForm that was being edited when the user
 pressed return
 */
- (void)cardFormWillEndEditingForReturn:(nonnull CardForm *)view;

/**
 Called when editing ends in the text field as a whole.

 This callback is always preceded by an callback for which
 specific subfield of the view ended its editing.
 */
- (void)cardFormDidEndEditing:(nonnull CardForm *)view;

/**
 Called when editing begins in the payment card field's number field.
 */
- (void)cardFormDidBeginEditingNumber:(nonnull CardForm *)view;

/**
 Called when editing ends in the payment card field's number field.
 */
- (void)cardFormDidEndEditingNumber:(nonnull CardForm *)view;

/**
 Called when editing begins in the payment card field's CVC field.
 */
- (void)cardFormBeginEditingCVC:(nonnull CardForm *)view;

/**
 Called when editing ends in the payment card field's CVC field.
 */
- (void)cardFormDidEndEditingCVC:(nonnull CardForm *)view;

/**
 Called when editing begins in the payment card field's expiration field.
 */
- (void)cardFormDidBeginEditingExpiration:(nonnull CardForm *)view;

/**
 Called when editing ends in the payment card field's expiration field.
 */
- (void)cardFormDidEndEditingExpiration:(nonnull CardForm *)view;

/**
 Called when editing begins in the payment card field's ZIP/postal code field.
 */
- (void)cardFormDidBeginEditingPostalCode:(nonnull CardForm *)view;

/**
 Called when editing ends in the payment card field's ZIP/postal code field.
 */
- (void)cardFormDidEndEditingPostalCode:(nonnull CardForm *)view;

@end
