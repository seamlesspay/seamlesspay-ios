/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "SPFormEncodable.h"


@interface SPCardParams : NSObject

@property(nonatomic, copy, nullable) NSString *number;

- (nullable NSString *)last4;

@property(nonatomic) NSUInteger expMonth;
@property(nonatomic) NSUInteger expYear;
@property(nonatomic, copy, nullable) NSString *cvc;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSString *currency;

@end
