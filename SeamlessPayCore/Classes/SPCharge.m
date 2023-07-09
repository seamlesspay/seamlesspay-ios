/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPCharge.h"

@implementation SPCharge

+ (instancetype)chargeWithResponseData:(NSData *)data {
  return [[SPCharge alloc] initWithResponseData:data];
}

- (instancetype)initWithResponseData:(NSData *)data {
  self = [super init];
  if (self) {

    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                             options:NSJSONReadingAllowFragments
                                               error:&error];

    if (error == nil && [obj isKindOfClass:[NSDictionary class]]) {

      NSMutableDictionary *dict = [obj mutableCopy];
      NSArray *keysForNullValues = [dict allKeysForObject:[NSNull null]];
      [dict removeObjectsForKeys:keysForNullValues];

      _chargeId = dict[@"id"];//
      _method = dict[@"method"];//
      _amount = dict[@"amount"];//
      _tip = dict[@"tip"];//
      _surchargeFeeAmount = dict[@"surchargeFeeAmount"];//
      _order = dict[@"order"];//
      _currency = dict[@"currency"];//
      _expDate = dict[@"expDate"];//
      _lastFour = dict[@"lastFour"];//
      _token = dict[@"token"];//
      _status = dict[@"status"];
      _statusCode = dict[@"statusCode"];//
      _statusDescription = dict[@"statusDescription"];//
      _ipAddress = dict[@"ipAddress"];//
      _authCode = dict[@"authCode"];//
      _batch = dict[@"batch"];//
      _paymentNetwork = dict[@"paymentNetwork"];//
      _businessCard = dict[@"businessCard"] ? YES : NO;//
      _fullyRefunded = dict[@"fullyRefunded"] ? YES : NO;//
      _adjustments = dict[@"adjustments"];//
      _paymentType = dict[@"paymentType"];//
      _accountType = dict[@"accountType"];//
      _refunds = dict[@"refunds"];//
      _transactionDate = dict[@"transactionDate"];//
      _verificationResults = dict[@"verificationResults"];//
      _createdAt = dict[@"createdAt"];//
      _updatedAt = dict[@"updatedAt"];//
    }
  }
  return self;
}

@end
