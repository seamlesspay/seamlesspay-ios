/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "SPPaymentMethodCard.h"

/**
 ### Refactoring SPPaymentCardTextField Guide

 Refactoring `SPPaymentCardTextField` from obj-c to Swift is a large task due to the size and complexity of the file, and it will require moderate to high effort. It is recommended to refactor this file in stages to prevent issues with the remainder of your application. Here's a refactoring guide:

 **Incremental refactoring**

 To smooth the transition, you can use Swift extensions to incrementally build out the needed functionality. Here's an example:

 ```swift
 extension SPPaymentCardTextField {
     var swiftProperty: Type {
         get { // return appropriate value
         }
         set(value) { // set appropriate value
         }
     }

     func swiftMethod() {
         // New Swift method code
     }
 }
 ```

 Add new features or changes using Swift extensions, while keeping the existing Objective-C code operational. As you build extensions and incrementally complete the changes, you will eventually replace the original Objective-C functionalities until the entire file is in Swift. Incremental refactoring allows for much lower risks and can prevent potential issues from bringing down an entire application.

 **Improving demo application**

 To determine the acceptability of refactoring, it is necessary to enhance the functionality scope of the demo application.

 **Testing and comparing**

 This task will require testing at all stages to ensure nothing breaks during the process. Keep the Objective-C version around for reference to ensure the Swift version behaves as expected.

 **High Effort**

 - **Class and Protocol Conversions:** Convert **`SPPaymentCardTextField`** and its delegate protocol **`SPPaymentCardTextFieldDelegate`** to Swift. Use **`@objc`** annotation for compatibility with Objective-C code. Include delegates, methods, and instance variables.
 - **Enums:** **`SPCardBrand`** needs to be translated into Swift. Swift enums are more powerful so you could use associated values if applicable.
 - **Methods:** All methods need to be converted to Swift. Be aware of any Objective-C specific behaviors in these methods, such as Nullable and Nonnull types.

 **Low Effort**

 - **Properties:** All properties need to be translated. Swift has different property attributes, for example, instead of nullable, Swift uses optional **`?`**.
 - **UI_APPEARANCE_SELECTOR:** Swift gets a free pass by not needing the attribute associated with it, but that just means you have to [make sure your property accessor methods are compatible](https://developer.apple.com/documentation/uikit/uiappearancecontainer).
 */

@class SPPaymentCardTextField, SPPaymentMethodCardParams;
@protocol SPPaymentCardTextFieldDelegate;

/**
 SPPaymentCardTextField is a text field with similar properties to UITextField,
 but specialized for collecting credit/debit card information. It manages
 multiple UITextFields under the hood to collect this information. It's
 designed to fit on a single line, and from a design perspective can be used
 anywhere a UITextField would be appropriate.
 */
IB_DESIGNABLE
@interface SPPaymentCardTextField : UIControl <UIKeyInput>

/**
 @see SPPaymentCardTextFieldDelegate
 */
@property(nonatomic, weak, nullable) IBOutlet id<SPPaymentCardTextFieldDelegate>
delegate;

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
 The current card number displayed by the field.

 May or may not be valid, unless `isValid` is true, in which case it is
 guaranteed to be valid.
 */
@property(nonatomic, readonly, nullable) NSString *cardNumber;

/**
 The current expiration month displayed by the field (1 = January, etc).

 May or may not be valid, unless `isValid` is true, in which case it is
 guaranteed to be valid.
 */
@property(nonatomic, readonly) NSUInteger expirationMonth;

/**
 The current expiration month displayed by the field, as a string. T

 This may or may not be a valid entry (i.e. "0") unless `isValid` is true.
 It may be also 0-prefixed (i.e. "01" for January).
 */
@property(nonatomic, readonly, nullable) NSString *formattedExpirationMonth;

/**
 The current expiration year displayed by the field, modulo 100
 (e.g. the year 2015 will be represented as 15).

 May or may not be valid, unless `isValid` is true, in which case it is
 guaranteed to be valid.
 */
@property(nonatomic, readonly) NSUInteger expirationYear;

/**
 The current expiration year displayed by the field, as a string.

 This is a 2-digit year (i.e. "15"), and may or may not be a valid entry
 unless `isValid` is true.
 */
@property(nonatomic, readonly, nullable) NSString *formattedExpirationYear;

@property(nonatomic, readonly, nullable) NSString *formattedExpirationDate;

/**
 The current card CVC displayed by the field.

 May or may not be valid, unless `isValid` is true, in which case it
 is guaranteed to be valid.
 */
@property(nonatomic, readonly, nullable) NSString *cvc;

/**
 The current card ZIP or postal code displayed by the field.
 */
@property(nonatomic, readonly, nullable) NSString *postalCode;

/**
 Controls if a postal code entry field can be displayed to the user.

 Default is NO (no postal code entry will ever be displayed).

 If YES, the type of code entry shown is controlled by the set `countryCode`
 value. Some country codes may result in no postal code entry being shown if
 those countries do not commonly use postal codes.
 */
@property(nonatomic, assign, readwrite) BOOL postalCodeEntryEnabled;

/**
 The two-letter ISO country code that corresponds to the user's billing address.

 If `postalCodeEntryEnabled` is YES, this controls which type of entry is
 allowed. If `postalCodeEntryEnabled` is NO, this property currently has no
 effect.

 If set to nil and postal code entry is enabled, the country from the user's
 current locale will be filled in. Otherwise the specific country code set will
 be used.

 By default this will fetch the user's current country code from NSLocale.
 */
@property(nonatomic, copy, nullable) NSString *countryCode;

/**
 Convenience property for creating an `SPPaymentMethodCardParams` from the
 currently entered information or programmatically setting the field's contents.
 For example, if you're using another library to scan your user's credit card
 with a camera, you can assemble that data into an `SPPaymentMethodCardParams`
 object and set this property to that object to prefill the fields you've
 collected.

 Accessing this property returns a *copied* `cardParams`. The only way to change
 properties in this object is to make changes to a `SPPaymentMethodCardParams`
 you own (retrieved from this text field if desired), and then set this property
 to the new value.
 */
@property(nonatomic, copy, readwrite, nonnull)SPPaymentMethodCardParams *cardParams;

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
 Returns the cvc image used for a card brand.
 Override this method in a subclass if you would like to provide custom images.
 @param cardBrand The brand of card entered.
 @return The cvc image used for a card brand.
 */
+ (nullable UIImage *)cvcImageForCardBrand:(SPCardBrand)cardBrand;

/**
 Returns the brand image used for a card brand.
 Override this method in a subclass if you would like to provide custom images.
 @param cardBrand The brand of card entered.
 @return The brand image used for a card brand.
 */
+ (nullable UIImage *)brandImageForCardBrand:(SPCardBrand)cardBrand;

/**
 Returns the error image used for a card brand.
 Override this method in a subclass if you would like to provide custom images.
 @param cardBrand The brand of card entered.
 @return The error image used for a card brand.
 */
+ (nullable UIImage *)errorImageForCardBrand:(SPCardBrand)cardBrand;

/**
 Returns the rectangle in which the receiver draws its brand image.
 @param bounds The bounding rectangle of the receiver.
 @return the rectangle in which the receiver draws its brand image.
 */
- (CGRect)brandImageRectForBounds:(CGRect)bounds;

/**
 Returns the rectangle in which the receiver draws the text fields.
 @param bounds The bounding rectangle of the receiver.
 @return The rectangle in which the receiver draws the text fields.
 */
- (CGRect)fieldsRectForBounds:(CGRect)bounds;

@end

/**
 This protocol allows a delegate to be notified when a payment text field's
 contents change, which can in turn be used to take further actions depending
 on the validity of its contents.
 */
@protocol SPPaymentCardTextFieldDelegate <NSObject>
@optional
/**
 Called when either the card number, expiration, or CVC changes. At this point,
 one can call `isValid` on the text field to determine, for example,
 whether or not to enable a button to submit the form. Example:

 - (void)paymentCardTextFieldDidChange:(SPPaymentCardTextField *)textField {
 self.paymentButton.enabled = textField.isValid;
 }

 @param textField the text field that has changed
 */
- (void)paymentCardTextFieldDidChange:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing begins in the text field as a whole.

 After receiving this callback, you will always also receive a callback for
 which specific subfield of the view began editing.
 */
- (void)paymentCardTextFieldDidBeginEditing:(nonnull SPPaymentCardTextField *)textField;

/**
 Notification that the user pressed the `return` key after completely filling
 out the SPPaymentCardTextField with data that passes validation.

 This is delivered *before* the corresponding
 `paymentCardTextFieldDidEndEditing:`

 @param textField The SPPaymentCardTextField that was being edited when the user
 pressed return
 */
- (void)paymentCardTextFieldWillEndEditingForReturn:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing ends in the text field as a whole.

 This callback is always preceded by an callback for which
 specific subfield of the view ended its editing.
 */
- (void)paymentCardTextFieldDidEndEditing:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing begins in the payment card field's number field.
 */
- (void)paymentCardTextFieldDidBeginEditingNumber:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing ends in the payment card field's number field.
 */
- (void)paymentCardTextFieldDidEndEditingNumber:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing begins in the payment card field's CVC field.
 */
- (void)paymentCardTextFieldDidBeginEditingCVC:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing ends in the payment card field's CVC field.
 */
- (void)paymentCardTextFieldDidEndEditingCVC:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing begins in the payment card field's expiration field.
 */
- (void)paymentCardTextFieldDidBeginEditingExpiration:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing ends in the payment card field's expiration field.
 */
- (void)paymentCardTextFieldDidEndEditingExpiration:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing begins in the payment card field's ZIP/postal code field.
 */
- (void)paymentCardTextFieldDidBeginEditingPostalCode:(nonnull SPPaymentCardTextField *)textField;

/**
 Called when editing ends in the payment card field's ZIP/postal code field.
 */
- (void)paymentCardTextFieldDidEndEditingPostalCode:(nonnull SPPaymentCardTextField *)textField;
@end
