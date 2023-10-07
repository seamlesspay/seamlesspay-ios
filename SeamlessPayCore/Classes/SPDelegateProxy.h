/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface SPDelegateProxy<__covariant DelegateType: NSObject <NSObject> *>: NSObject

@property(nonatomic, weak) DelegateType delegate;
- (instancetype)init;

@end
