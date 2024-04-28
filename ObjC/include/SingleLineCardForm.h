/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 ### Refactoring SingleLineCardForm Guide

 Refactoring `SingleLineCardForm` from obj-c to Swift is a large task due to the size and complexity of the file, and it will require moderate to high effort. It is recommended to refactor this file in stages to prevent issues with the remainder of your application. Here's a refactoring guide:

 **Incremental refactoring**

 To smooth the transition, you can use Swift extensions to incrementally build out the needed functionality. Here's an example:

 ```swift
 extension SingleLineCardForm {
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

 - **Class and Protocol Conversions:** Convert **`SingleLineCardForm`** and its delegate protocol **`SingleLineCardForm`** to Swift. Use **`@objc`** annotation for compatibility with Objective-C code. Include delegates, methods, and instance variables.
 - **Enums:** **`SPCardBrand`** needs to be translated into Swift. Swift enums are more powerful so you could use associated values if applicable.
 - **Methods:** All methods need to be converted to Swift. Be aware of any Objective-C specific behaviors in these methods, such as Nullable and Nonnull types.

 **Low Effort**

 - **Properties:** All properties need to be translated. Swift has different property attributes, for example, instead of nullable, Swift uses optional **`?`**.
 - **UI_APPEARANCE_SELECTOR:** Swift gets a free pass by not needing the attribute associated with it, but that just means you have to [make sure your property accessor methods are compatible](https://developer.apple.com/documentation/uikit/uiappearancecontainer).
 */

#import <UIKit/UIKit.h>
#import "SPPaymentMethodCard.h"
#import "CardForm.h"

@class SingleLineCardForm;
@protocol SingleLineCardFormDelegate;

/**
 SingleLineCardForm is a text field with similar properties to UITextField,
 but specialized for collecting credit/debit card information. It manages
 multiple UITextFields under the hood to collect this information. It's
 designed to fit on a single line, and from a design perspective can be used
 anywhere a UITextField would be appropriate.
 */
IB_DESIGNABLE
@interface SingleLineCardForm : CardForm

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
@property(nonatomic, copy, null_resettable) UIColor *textColor UI_APPEARANCE_SELECTOR;

/**
 The text color to be used when the user has entered invalid information,
 such as an invalid card number.

 Default is [UIColor redColor]. Set this property to nil to reset to the
 default.
 */
@property(nonatomic, copy, null_resettable) UIColor *textErrorColor UI_APPEARANCE_SELECTOR;

/**
 The text placeholder color used in each child field.

 This will also set the color of the card placeholder icon.

 Default is [UIColor systemGray2Color]. Set this property to nil to reset to the
 default.
 */
@property(nonatomic, copy, null_resettable) UIColor *placeholderColor UI_APPEARANCE_SELECTOR;

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
@property(nonatomic, copy, nullable) IBInspectable NSString *expirationPlaceholder;

/**
 The placeholder for the cvc field. Defaults to @"CVC".
 */
@property(nonatomic, copy, nullable) IBInspectable NSString *cvcPlaceholder;

/**
 The placeholder for the postal code field. Defaults to @"ZIP" for United States
 or @"Postal" for all other country codes.
 */
@property(nonatomic, copy, nullable) IBInspectable NSString *postalCodePlaceholder;

/**
 The cursor color for the field.

 This is a proxy for the view's tintColor property, exposed for clarity only
 (in other words, calling setCursorColor is identical to calling setTintColor).
 */
@property(nonatomic, copy, null_resettable) UIColor *cursorColor UI_APPEARANCE_SELECTOR;

/**
 The border color for the field.

 Can be nil (in which case no border will be drawn).

 Default is [UIColor systemGray2Color].
 */
@property(nonatomic, copy, nullable) UIColor *borderColor UI_APPEARANCE_SELECTOR;

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
@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance UI_APPEARANCE_SELECTOR;

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
 Returns the rectangle in which the receiver draws the text fields.
 @param bounds The bounding rectangle of the receiver.
 @return The rectangle in which the receiver draws the text fields.
 */
- (CGRect)fieldsRectForBounds:(CGRect)bounds;

@end

