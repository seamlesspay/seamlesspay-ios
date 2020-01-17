//
//  SPFormEncoder.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

@protocol SPFormEncodable;

@interface SPFormEncoder : NSObject

+ (nonnull NSDictionary *)dictionaryForObject:(nonnull NSObject<SPFormEncodable> *)object;

+ (nonnull NSString *)stringByURLEncoding:(nonnull NSString *)string;

+ (nonnull NSString *)stringByReplacingSnakeCaseWithCamelCase:(nonnull NSString *)input;

+ (nonnull NSString *)queryStringFromParameters:(nonnull NSDictionary *)parameters;

@end
