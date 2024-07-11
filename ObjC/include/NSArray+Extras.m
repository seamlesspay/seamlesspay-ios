/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

- (nullable id)sp_boundSafeObjectAtIndex:(NSInteger)index {
  if (index + 1 > (NSInteger)self.count || index < 0) {
    return nil;
  }
  return self[index];
}

@end

void linkNSArrayCategory(void) {}
