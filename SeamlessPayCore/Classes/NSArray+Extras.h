/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extras)

- (nullable id)sp_boundSafeObjectAtIndex:(NSInteger)index;
- (NSArray *)sp_arrayByRemovingNulls;

@end

NS_ASSUME_NONNULL_END

void linkNSArrayCategory(void);
