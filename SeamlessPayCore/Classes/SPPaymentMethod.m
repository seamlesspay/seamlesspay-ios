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

      NSLog(@"SPPaymentMethod initWithResponseData: %@",obj);

      _token = obj[@"token"]  ?: nil;
      _name = obj[@"name"]  ?: nil;
      _nickname = obj[@"nickname"]  ?: nil;
      _paymentType = obj[@"paymentType"]  ?: nil;
      _lastfour = obj[@"lastfour"]  ?: nil;
      _expDate = obj[@"expDate"]  ?: nil;

      if ([obj[@"customer"] isKindOfClass:[NSDictionary class]]) {
        _customerId = obj[@"customer"][@"id"];
      }

      if ([obj[@"billingAddress"] isKindOfClass:[NSDictionary class]]) {
        _billingAddress = [[SPAddress alloc] initWithline1:obj[@"billingAddress"][@"line1"] ?: nil
                                                     line2:obj[@"billingAddress"][@"line2"] ?: nil
                                                      city:obj[@"billingAddress"][@"city"] ?: nil
                                                   country:obj[@"billingAddress"][@"country"] ?: nil
                                                     state:obj[@"billingAddress"][@"state"] ?: nil
                                                postalCode:obj[@"billingAddress"][@"postalCode"] ?: nil];
      }
      _phoneNumber = obj[@"phoneNumber"]  ?: nil;
      _email = obj[@"email"]  ?: nil;
      _routingNumber = obj[@"routingNumber"]  ?: nil;
      _bankAccountType = obj[@"bankAccountType"]  ?: nil;
      _pinNumber = obj[@"pinNumber"] ?: nil;
      _company = obj[@"company"]  ?: nil;
      _verificationResults = dict[@"verificationResults"]  ?: nil;
      _paymentNetwork = dict[@"paymentNetwork"]  ?: nil;
    }
  }

  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    _token = dict[@"token"] ?: nil;
    _name = dict[@"name"] ?: nil;
    _nickname = dict[@"nickname"] ?: nil;
    _paymentType = dict[@"paymentType"] ?: nil;
    _lastfour = dict[@"lastfour"] ?: nil;
    _expDate = dict[@"expDate"]  ?: nil;
    _phoneNumber = dict[@"phoneNumber"]  ?: nil;
    _email = dict[@"email"]  ?: nil;
    _routingNumber = dict[@"routingNumber"]  ?: nil;
    _bankAccountType = dict[@"bankAccountType"]  ?: nil;
    _pinNumber = dict[@"pinNumber"]  ?: nil;
    _company = dict[@"company"]  ?: nil;
    _verificationResults = dict[@"verificationResults"]  ?: nil;
    _customerId = dict[@"customerId"]  ?: nil;

    if ([dict[@"billingAddress"] isKindOfClass:[NSDictionary class]]) {
      _billingAddress = [[SPAddress alloc] initWithline1:dict[@"billingAddress"][@"line1"] ?: nil
                                                   line2:dict[@"billingAddress"][@"line2"] ?: nil
                                                    city:dict[@"billingAddress"][@"city"] ?: nil
                                                 country:dict[@"billingAddress"][@"country"] ?: nil
                                                   state:dict[@"billingAddress"][@"state"] ?: nil
                                              postalCode:dict[@"billingAddress"][@"postalCode"] ?: nil];
    }

  }
  return self;
}

- (NSDictionary *)dictionary {

  NSMutableDictionary *params = [ @{
    @"token" : _token ?: @"",
    @"name" : _name ?: @"",
    @"paymentType" : _paymentType ?: @"",
    @"lastfour" : _lastfour ?: @"",
    @"expDate" : _expDate ?: @"",
    @"phoneNumber" : _phoneNumber ?: @"",
    @"email" : _email ?: @"",
    @"routingNumber" : _routingNumber ?: @"",
    @"bankAccountType" : _bankAccountType ?: @"",
    @"pinNumber" : _pinNumber ?: @"",
    @"company" : _company ?: @"",
    @"verificationResults" : _verificationResults ?: @"",
    @"customerId" : _customerId ?: @"",
    @"billingAddress" : _billingAddress && [_billingAddress dictionary] ? [_billingAddress dictionary] : @""
  } mutableCopy];

  NSArray *keysForNullValues = [params allKeysForObject:@""];
  keysForNullValues = [keysForNullValues arrayByAddingObjectsFromArray: [params allKeysForObject:[NSNull null]]];
  [params removeObjectsForKeys:keysForNullValues];

  return params;
}

@end
