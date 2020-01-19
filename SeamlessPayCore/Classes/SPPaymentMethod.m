/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPPaymentMethod.h"

@implementation SPPaymentMethod

+ (instancetype)tokenWithResponseData:(NSData *)data {
  return [[SPPaymentMethod alloc] initWithResponseData:data];
}

- (instancetype)initWithResponseData:(NSData *)data {
  self = [super init];
  if (self) {

    NSError *error = nil;
    id dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments
                                          error:&error];

    if (error == nil && [dict isKindOfClass:[NSDictionary class]]) {

      NSMutableDictionary *obj = [dict mutableCopy];
      NSArray *keysForNullValues = [obj allKeysForObject:[NSNull null]];
      [obj removeObjectsForKeys:keysForNullValues];

      // NSLog(@"%@",obj);

      _token = [obj[@"token"] copy];
      _name = [obj[@"name"] copy];
      _txnType = [obj[@"txnType"] copy];
      _lastfour = [obj[@"lastfour"] copy];
      _expDate = [obj[@"expDate"] copy];
      _billingAddress = [obj[@"billingAddress"] copy];
      _billingAddress2 = [obj[@"billingAddress2"] copy];
      _billingCity = [obj[@"billingCity"] copy];
      _billingState = [obj[@"billingState"] copy];
      _billingZip = [obj[@"billingZip"] copy];
      _phoneNumber = [obj[@"phoneNumber"] copy];
      _email = [obj[@"email"] copy];
      _nickname = [obj[@"nickname"] copy];
      _routingNumber = [obj[@"routingNumber"] copy];
      _bankAccountType = [obj[@"bankAccountType"] copy];
      _pinNumber = [obj[@"pinNumber"] copy];
      _company = [obj[@"company"] copy];
    }
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    _token = [dict[@"token"] copy];
    _name = [dict[@"name"] copy];
    _txnType = [dict[@"txnType"] copy];
    _lastfour = [dict[@"lastfour"] copy];
    _expDate = [dict[@"expDate"] copy];
    _billingAddress = [dict[@"billingAddress"] copy];
    _billingAddress2 = [dict[@"billingAddress2"] copy];
    _billingCity = [dict[@"billingCity"] copy];
    _billingState = [dict[@"billingState"] copy];
    _billingZip = [dict[@"billingZip"] copy];
    _phoneNumber = [dict[@"phoneNumber"] copy];
    _email = [dict[@"email"] copy];
    _nickname = [dict[@"nickname"] copy];
    _routingNumber = [dict[@"routingNumber"] copy];
    _bankAccountType = [dict[@"bankAccountType"] copy];
    _pinNumber = [dict[@"pinNumber"] copy];
    _company = [dict[@"company"] copy];
  }
  return self;
}

- (NSDictionary *)dictionary {
  return @{
    @"token" : _token ?: @"",
    @"name" : _name ?: @"",
    @"txnType" : _txnType ?: @"",
    @"lastfour" : _lastfour ?: @"",
    @"expDate" : _expDate ?: @"",
    @"billingAddress" : _billingAddress ?: @"",
    @"billingAddress2" : _billingAddress2 ?: @"",
    @"billingCity" : _billingCity ?: @"",
    @"billingState" : _billingState ?: @"",
    @"billingZip" : _billingZip ?: @"",
    @"phoneNumber" : _phoneNumber ?: @"",
    @"email" : _email ?: @"",
    @"company" : _company ?: @"",
    @"nickname" : _nickname ?: @"",
    @"routingNumber" : _routingNumber ?: @"",
    @"bankAccountType" : _bankAccountType ?: @"",
    @"pinNumber" : _pinNumber ?: @""
  };
}

@end
