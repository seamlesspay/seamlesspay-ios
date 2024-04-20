/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "SPPaymentMethodCard.h"

@class CardForm;
@protocol CardFormDelegate;

IB_DESIGNABLE
@interface CardForm : UIControl <UIKeyInput>

/**
 @see CardFormDelegate
 */
@property(nonatomic, weak, nullable) IBOutlet id<CardFormDelegate> delegate;

/**
 The font used in each child field. Default is [UIFont systemFontOfSize:18].

 Set this property to nil to reset to the default.
 */
@property(nonatomic, copy, null_resettable) UIFont *font UI_APPEARANCE_SELECTOR;

/**
 The text color to be used when entering valid text. Default is [UIColor
 labelColor].

 Set this property to nil to reset to the default.
 */
@property(nonatomic, copy, null_resettable)
UIColor *textColor UI_APPEARANCE_SELECTOR;

/**
 The text color to be used when the user has entered invalid information,
 such as an invalid card number.

 Default is [UIColor redColor]. Set this property to nil to reset to the
 default.
 */
@property(nonatomic, copy, null_resettable)
UIColor *textErrorColor UI_APPEARANCE_SELECTOR;

/**
 The text placeholder color used in each child field.

 This will also set the color of the card placeholder icon.

 Default is [UIColor systemGray2Color]. Set this property to nil to reset to the
 default.
 */
@property(nonatomic, copy, null_resettable)
UIColor *placeholderColor UI_APPEARANCE_SELECTOR;

/**
 The placeholder for the card number field.

 Default is @"4242424242424242".

 If this is set to something that resembles a card number, it will automatically
 format it as such (in other words, you don't need to add spaces to this
 string).
 */
@property(nonatomic, copy, nullable) IBInspectable NSString *numberPlaceholder;

/**
 The placeholder for the expiration field. Defaults to @"MM/YY".
 */
@property(nonatomic, copy, nullable)
IBInspectable NSString *expirationPlaceholder;

/**
 The placeholder for the cvc field. Defaults to @"CVC".
 */
@property(nonatomic, copy, nullable) IBInspectable NSString *cvcPlaceholder;

/**
 The placeholder for the postal code field. Defaults to @"ZIP" for United States
 or @"Postal" for all other country codes.
 */
@property(nonatomic, copy, nullable)
IBInspectable NSString *postalCodePlaceholder;

/**
 The cursor color for the field.

 This is a proxy for the view's tintColor property, exposed for clarity only
 (in other words, calling setCursorColor is identical to calling setTintColor).
 */
@property(nonatomic, copy, null_resettable)
UIColor *cursorColor UI_APPEARANCE_SELECTOR;

/**
 The border color for the field.

 Can be nil (in which case no border will be drawn).

 Default is [UIColor systemGray2Color].
 */
@property(nonatomic, copy, nullable)
UIColor *borderColor UI_APPEARANCE_SELECTOR;

/**
 The width of the field's border.

 Default is 1.0.
 */
@property(nonatomic, assign) CGFloat borderWidth UI_APPEARANCE_SELECTOR;

/**
 The corner radius for the field's border.

 Default is 5.0.
 */
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/**
 The keyboard appearance for the field.

 Default is UIKeyboardAppearanceDefault.
 */
@property(nonatomic, assign)
UIKeyboardAppearance keyboardAppearance UI_APPEARANCE_SELECTOR;

/**
 This behaves identically to setting the inputView for each child text field.
 */
@property(nonatomic, strong, nullable) UIView *inputView;

/**
 This behaves identically to setting the inputAccessoryView for each child text
 field.
 */
@property(nonatomic, strong, nullable) UIView *inputAccessoryView;

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

/**
 Returns the rectangle in which the receiver draws the text fields.
 @param bounds The bounding rectangle of the receiver.
 @return The rectangle in which the receiver draws the text fields.
 */
- (CGRect)fieldsRectForBounds:(CGRect)bounds;

- (void)commonInit;

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
