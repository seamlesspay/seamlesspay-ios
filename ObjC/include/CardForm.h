/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "CardFormViewModel.h"
#import "CardFieldDisplay.h"
#import "CardFormDelegate.h"

//typedef NS_ENUM(NSInteger, CardFieldDisplay) {
//  CardFieldDisplayNone,
//  CardFieldDisplayOptional,
//  CardFieldDisplayRequired,
//};

@class CardForm;
@protocol CardFormDelegate;
@protocol CardFormProtocol;

@interface CardForm : UIControl <UIKeyInput, CardFormProtocol>

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
