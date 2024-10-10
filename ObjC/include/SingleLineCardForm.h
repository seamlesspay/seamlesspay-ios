/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "CardFieldDisplay.h"
#import "CardFormDelegate.h"

/**
 SingleLineCardForm is a text field with similar properties to UITextField,
 but specialized for collecting credit/debit card information. It manages
 multiple UITextFields under the hood to collect this information. It's
 designed to fit on a single line, and from a design perspective can be used
 anywhere a UITextField would be appropriate.
 */
@interface SingleLineCardForm : UIControl <UIKeyInput, CardForm, SPFormTextFieldDelegate>

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
 Resets all of the contents of all of the fields. If the field is currently
 being edited, the number field will become selected.
 */
- (void)clear;

//TODO: Make internal/private
- (void)setCVCDisplayConfig:(CardFieldDisplay)displayConfig;
- (void)setPostalCodeDisplayConfig:(CardFieldDisplay)displayConfig;

/**
 Returns the rectangle in which the receiver draws the text fields.
 @param bounds The bounding rectangle of the receiver.
 @return The rectangle in which the receiver draws the text fields.
 */
- (CGRect)fieldsRectForBounds:(CGRect)bounds;

@end

