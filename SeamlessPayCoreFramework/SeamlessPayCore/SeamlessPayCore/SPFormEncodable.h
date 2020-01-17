//
//  SPFormEncodable.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol SPFormEncodable <NSObject>

+ (nullable NSString *)rootObjectName;

+ (NSDictionary *)propertyNamesToFormFieldNamesMapping;


@end

NS_ASSUME_NONNULL_END
