/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@protocol SPFormEncodable;

@interface SPFormEncoder : NSObject

+ (nonnull NSDictionary *)dictionaryForObject:(nonnull NSObject<SPFormEncodable> *)object;
+ (nonnull NSString *)stringByURLEncoding:(nonnull NSString *)string;
+ (nonnull NSString *)stringByReplacingSnakeCaseWithCamelCase:(nonnull NSString *)input;
+ (nonnull NSString *)queryStringFromParameters:(nonnull NSDictionary *)parameters;

@end
