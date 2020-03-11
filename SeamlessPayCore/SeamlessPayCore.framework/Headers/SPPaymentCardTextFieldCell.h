/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import "SPPaymentCardTextField.h"
#import "SPTheme.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPPaymentCardTextFieldCell : UITableViewCell

@property(nonatomic, weak, readonly) SPPaymentCardTextField *paymentField;
@property(nonatomic, copy) SPTheme *theme;
@property(nonatomic, weak) UIView *inputAccessoryView;

- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
