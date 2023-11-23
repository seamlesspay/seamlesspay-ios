/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCardParams.h"

#import "SPCardValidator.h"

@implementation SPCardParams

- (instancetype)init {
  self = [super init];
  if (self) {}
  return self;
}

- (NSString *)last4 {
  if (self.number && self.number.length >= 4) {
    return [self.number substringFromIndex:(self.number.length - 4)];
  } else {
    return nil;
  }
}

#pragma mark - Description

- (NSString *)description {
  NSArray *props = @[
    // Object
    [NSString
     stringWithFormat:@"%@: %p", NSStringFromClass([self class]), self],

    // Basic card details
    [NSString stringWithFormat:@"last4 = %@", self.last4],
    [NSString stringWithFormat:@"expMonth = %lu", (unsigned long)self.expMonth],
    [NSString stringWithFormat:@"expYear = %lu", (unsigned long)self.expYear],
    [NSString stringWithFormat:@"cvc = %@", (self.cvc) ? @"<redacted>" : nil],

    // Additional card details (alphabetical)
    [NSString stringWithFormat:@"currency = %@", self.currency],

    // Cardholder details
    [NSString stringWithFormat:@"name = %@", (self.name) ? @"<redacted>" : nil],
  ];

  return [NSString
          stringWithFormat:@"<%@>", [props componentsJoinedByString:@"; "]];
}

+ (NSString *)rootObjectName {
  return @"card";
}

@end
