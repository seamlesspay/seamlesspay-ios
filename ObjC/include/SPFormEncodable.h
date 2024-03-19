/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SPFormEncodable <NSObject>

+ (nullable NSString *)rootObjectName;
+ (NSDictionary *)propertyNamesToFormFieldNamesMapping;

@end

NS_ASSUME_NONNULL_END
