/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPError.h"

@implementation SPError

+ (instancetype)errorWithData:(NSData *_Nullable)data error:(NSError *_Nullable)error {
  SPError *spError = [SPError errorWithResponse: data];
  if (spError) {
    return spError;
  }
  spError = [SPError errorWithNSError: error];
  if (spError) {
    return spError;
  }

  return [SPError unknownError];
}

+ (instancetype)errorWithResponse:(NSData *)data {
  NSError *error = nil;
  
  if (data) {
    
    id errobj = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingAllowFragments
                                                  error:&error];
    if (error == nil && [errobj isKindOfClass:[NSDictionary class]]) {

      SPError *sperror =  [SPError errorWithDomain:@"api.seamlesspay.com"
                                              code:[errobj[@"code"] integerValue]
                                          userInfo:@{
        NSLocalizedDescriptionKey :
          [SPError descriptionWithResponse:errobj]
      }];
      return sperror;
    }
  }

  return nil;
}

+ (instancetype)errorWithNSError:(NSError *)error {
  if (error) {
    return [SPError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
  }
  return nil;
}

+ (instancetype)unknownError {
  return [SPError errorWithDomain:@"api.seamlesspay.com"
                             code:29
                         userInfo:@{NSLocalizedDescriptionKey: @"Unknown Error"}];
}

+ (NSString *)descriptionWithResponse:(NSDictionary *)dict {
  NSMutableString *s = [NSMutableString new];
  [s appendFormat:@"Name=%@\n", dict[@"name"] ?: @""];
  [s appendFormat:@"Message=%@\n", dict[@"message"] ?: @""];
  [s appendFormat:@"ClassName=%@\n", dict[@"className"] ?: @""];
  [s appendFormat:@"StatusCode=%@\n",
   dict[@"data"] && dict[@"data"][@"statusCode"]
   ? dict[@"data"][@"statusCode"]
                 : @""];
  [s appendFormat:@"StatusDescription=%@\n",
   dict[@"data"] && dict[@"data"][@"statusDescription"]
   ? dict[@"data"][@"statusDescription"]
                 : @""];
  [s appendFormat:@"Errors=%@\n", dict[@"errors"] ?: @""];
  return s;
}

@end
