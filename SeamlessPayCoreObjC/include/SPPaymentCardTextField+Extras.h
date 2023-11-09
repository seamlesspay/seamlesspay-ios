/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPPaymentCardTextField.h"

@class SPFormTextField;

@interface SPPaymentCardTextField (Extras)
@property(nonatomic, strong) NSArray<SPFormTextField *> *allFields;
- (void)commonInit;
@end
