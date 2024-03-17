/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "NSDictionary+Extras.h"

#import "NSArray+Extras.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDictionary (Extras)

- (NSDictionary *)sp_dictionaryByRemovingNulls {
  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

  [self
   enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
    if ([obj isKindOfClass:[NSArray class]]) {
      // Save array after removing any null values
      result[key] = [(NSArray *)obj sp_arrayByRemovingNulls];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
      // Save dictionary after removing any null values
      result[key] = [(NSDictionary *)obj sp_dictionaryByRemovingNulls];
    } else if ([obj isKindOfClass:[NSNull class]]) {
      // Skip null value
    } else {
      // Save other value
      result[key] = obj;
    }
  }];

  // Make immutable copy
  return [result copy];
}

- (NSDictionary<NSString *, NSString *> *)sp_dictionaryByRemovingNonStrings {
  NSMutableDictionary<NSString *, NSString *> *result = [[NSMutableDictionary alloc] init];

  [self
   enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
    if ([key isKindOfClass:[NSString class]] &&
        [obj isKindOfClass:[NSString class]]) {
      // Save valid key/value pair
      result[key] = obj;
    }
  }];

  // Make immutable copy
  return [result copy];
}

#pragma mark - Getters

- (nullable NSArray *)sp_arrayForKey:(NSString *)key {
  id value = self[key];
  if (value && [value isKindOfClass:[NSArray class]]) {
    return value;
  }
  return nil;
}

- (BOOL)sp_boolForKey:(NSString *)key or:(BOOL)defaultValue {
  id value = self[key];
  if (value) {
    if ([value isKindOfClass:[NSNumber class]]) {
      return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
      NSString *string = [(NSString *)value lowercaseString];
      // boolValue on NSString is true for "Y", "y", "T", "t", or 1-9
      if ([string isEqualToString:@"true"] || [string boolValue]) {
        return YES;
      } else {
        return NO;
      }
    }
  }
  return defaultValue;
}

- (nullable NSDate *)sp_dateForKey:(NSString *)key {
  id value = self[key];
  if (value && ([value isKindOfClass:[NSNumber class]] ||
                [value isKindOfClass:[NSString class]])) {
    double timeInterval = [value doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
  }
  return nil;
}

- (nullable NSDictionary *)sp_dictionaryForKey:(NSString *)key {
  id value = self[key];
  if (value && [value isKindOfClass:[NSDictionary class]]) {
    return value;
  }
  return nil;
}

- (NSInteger)sp_intForKey:(NSString *)key or:(NSInteger)defaultValue {
  id value = self[key];
  if (value && ([value isKindOfClass:[NSNumber class]] ||
                [value isKindOfClass:[NSString class]])) {
    return [value integerValue];
  }
  return defaultValue;
}

- (nullable NSDictionary *)sp_numberForKey:(NSString *)key {
  id value = self[key];
  if (value && [value isKindOfClass:[NSNumber class]]) {
    return value;
  }
  return nil;
}

- (nullable NSString *)sp_stringForKey:(NSString *)key {
  id value = self[key];
  if (value && [value isKindOfClass:[NSString class]]) {
    return value;
  }
  return nil;
}

@end

void linkNSDictionaryCategory(void) {}

NS_ASSUME_NONNULL_END
