//
//  NSArray+Extras.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "NSArray+Extras.h"

#import "NSDictionary+Extras.h"

@implementation NSArray (Extras)

- (nullable id)sp_boundSafeObjectAtIndex:(NSInteger)index {
    if (index + 1 > (NSInteger)self.count || index < 0) {
        return nil;
    }
    return self[index];
}

- (NSArray *)sp_arrayByRemovingNulls {
    NSMutableArray *result = [[NSMutableArray alloc] init];

    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]]) {
            // Save array after removing any null values
            [result addObject:[(NSArray *)obj sp_arrayByRemovingNulls]];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            // Save dictionary after removing any null values
            [result addObject:[(NSDictionary *)obj sp_dictionaryByRemovingNulls]];
        } else if ([obj isKindOfClass:[NSNull class]]) {
            // Skip null value
        } else {
            // Save other value
            [result addObject:obj];
        }
    }

    // Make immutable copy
    return [result copy];
}

@end

void linkNSArrayCategory(void){}
