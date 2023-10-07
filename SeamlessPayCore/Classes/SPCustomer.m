/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCustomer.h"

@implementation SPCustomer

+ (instancetype)customerWithResponseData:(NSData *)data {
  return [[SPCustomer alloc] initWithResponseData:data];
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

      NSLog(@"SPCustomer initWithResponseData: %@", obj);

      SPAddress *address = [[SPAddress alloc] initWithline1:obj[@"address"][@"line1"] ?: nil
                                                      line2:obj[@"address"][@"line2"] ?: nil
                                                       city:obj[@"address"][@"city"] ?: nil
                                                    country:obj[@"address"][@"country"] ?: nil
                                                      state:obj[@"address"][@"state"] ?: nil
                                                 postalCode:obj[@"address"][@"postalCode"] ?: nil];

      _customerId = obj[@"id"] ?: nil;
      _name = obj[@"name"] ?: nil;
      _email = obj[@"email"] ?: nil;
      _address = address;
      _companyName = obj[@"companyName"] ?: nil;
      _notes = obj[@"description"] ?: nil;
      _website = obj[@"website"] ?: nil;
      _metadata = obj[@"metadata"] ?: nil;
      _phone = obj[@"phone"] ?: nil;
      _createdAt = obj[@"createdAt"] ?: nil;
      _updatedAt = obj[@"updatedAt"] ?: nil;


      if (error == nil &&
          [obj[@"paymentMethods"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray new];
        for (NSDictionary *dict in obj[@"paymentMethods"]) {
          SPPaymentMethod *pm =
          [[SPPaymentMethod alloc] initWithDictionary:dict];
          [arr addObject:pm];
        }
        _paymentMethods = arr;
      }
    }
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name
                       email:(NSString *)email
                       phone:(NSString *)phone
                 companyName:(NSString *)companyName
                       notes:(NSString *)notes
                     website:(NSString *)website
                    metadata:(NSString *)metadata
                     address:(SPAddress *)address
              paymentMethods:(NSArray *)paymentMethods {

  self = [super init];
  if (self) {

    _name = name;
    _email = email;
    _phone = phone;
    _companyName = companyName;
    _notes = notes;
    _website = website;
    _metadata = metadata;
    _address = address;
    _paymentMethods = paymentMethods;
  }
  return self;
}


- (NSDictionary *)dictionary {

  NSMutableArray *arr = nil;
  if (_paymentMethods) {
    arr = [NSMutableArray new];
    for (SPPaymentMethod *pm in _paymentMethods) {
      [arr addObject:[pm dictionary]];
    }
  }

  NSMutableDictionary *params = [@{

    @"customerId" : _customerId ?: @"",
    @"name" : _name,
    @"email" : _email ?: @"",
    @"address" : _address && [_address dictionary] ? [_address dictionary] : @"",
    @"phone" : _phone ?: @"",
    @"companyName" : _companyName ?: @"",
    @"notes" : _notes ?: @"",
    @"website" : _website ?: @"",
    @"metadata" : _metadata ?: @"",
    @"createdAt" : _createdAt ?: @"",
    @"updatedAt" : _updatedAt ?: @"",
    @"paymentMethods" : arr?: @""

  } mutableCopy];

  NSArray *keysForNullValues = [params allKeysForObject:@""];
  keysForNullValues = [keysForNullValues arrayByAddingObjectsFromArray: [params allKeysForObject:[NSNull null]]];
  [params removeObjectsForKeys:keysForNullValues];

  return [params count] !=0 ? params : nil;
}

@end
