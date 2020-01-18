//
//  NSArray+Extras.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extras)

- (nullable id)sp_boundSafeObjectAtIndex:(NSInteger)index;
- (NSArray *)sp_arrayByRemovingNulls;

@end

NS_ASSUME_NONNULL_END

void linkNSArrayCategory(void);
