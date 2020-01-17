//
//  SMPError.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SMPError.h"

@implementation SMPError

+ (instancetype)errorWithResponse:(NSData*)data
{
    NSError *error = nil;
    id errobj = [NSJSONSerialization JSONObjectWithData:data
                                             options:NSJSONReadingAllowFragments
                                               error:&error];
    if (error == nil && [errobj isKindOfClass:[NSDictionary class]]) {
        
       return [SMPError errorWithDomain:@"api.seamlesspay.com"
                            code:[errobj[@"code"] integerValue]
                        userInfo:@{NSLocalizedDescriptionKey:[SMPError descriptionWithResponse:errobj]}];
        
    }
    
    return nil;
}

+ (NSString *)descriptionWithResponse:(NSDictionary *)dict
{
    NSMutableString *s = [NSMutableString new];
    [s appendFormat:@"Name=%@\n",dict[@"name"] ? : @""];
    [s appendFormat:@"Message=%@\n",dict[@"message"] ? : @""];
    [s appendFormat:@"ClassName=%@\n",dict[@"className"] ? : @""];
    [s appendFormat:@"StatusCode=%@\n",dict[@"data"] && dict[@"data"][@"statusCode"] ? dict[@"data"][@"statusCode"] : @""];
    [s appendFormat:@"StatusDescription=%@\n",dict[@"data"] && dict[@"data"][@"statusDescription"] ? dict[@"data"][@"statusDescription"] : @""];    
    [s appendFormat:@"Errors=%@\n",dict[@"errors"] ? : @""];
    return s;
}

@end
