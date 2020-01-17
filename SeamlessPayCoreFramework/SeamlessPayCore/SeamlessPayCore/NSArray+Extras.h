//
//  NSArray+Extras.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extras)

- (nullable id)sp_boundSafeObjectAtIndex:(NSInteger)index;
- (NSArray *)sp_arrayByRemovingNulls;

@end

NS_ASSUME_NONNULL_END

void linkNSArrayCategory(void);
