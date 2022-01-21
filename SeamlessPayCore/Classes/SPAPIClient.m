/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPAPIClient.h"

static const NSString *k_APIHostURL;
static const NSString *k_APIHostURLLive = @"https://api.seamlesspay.com";
static const NSString *k_APIHostURLSandbox = @"https://sandbox.seamlesspay.com";
static const NSString *k_PanVaultHostURLLive = @"https://pan-vault.seamlesspay.com";
static const NSString *k_PanVaultHostURLSandbox = @"https://sandbox-pan-vault.seamlesspay.com";
static const NSString *k_APIVersionNumber = @"v2019";
static const NSTimeInterval k_TimeoutInterval = 15.0;

static SPAPIClient *sharedInstance = nil;

@interface SPAPIClient () {
  NSString *_APIHostURL;
  NSString *_PanVaulHostURL;
}
@property (nonatomic) NSDate *appOpenTime;
@end

@implementation SPAPIClient

+ (instancetype)getSharedInstance {
  if (!sharedInstance) {
    sharedInstance = [[super allocWithZone:NULL] init];
  }
  return sharedInstance;
}

- (void)setSecretKey:(NSString *)secretKey
           publishableKey:(NSString *)publishableKey
             sandbox:(BOOL)sandbox {
  if (sandbox) {
    _APIHostURL = [k_APIHostURLSandbox copy];
    _PanVaulHostURL = [k_PanVaultHostURLSandbox copy];
  } else {
    _APIHostURL = [k_APIHostURLLive copy];
    _PanVaulHostURL = [k_PanVaultHostURLLive copy];
  }

  _secretKey = [secretKey ?: publishableKey copy];
  _publishableKey = [publishableKey copy];
    
  self.appOpenTime = [NSDate date];
}

- (void)createCustomerWithName:(NSString *)name
                         email:(NSString *)email
                       address:(NSString *)address
                      address2:(NSString *)address2
                          city:(NSString *)city
                       country:(NSString *)country
                         state:(NSString *)state
                           zip:(NSString *)zip
                       company:(NSString *)company
                         phone:(NSString *)phone
                       website:(NSString *)website
                paymentMethods:(NSArray *)paymentMethods
                      metadata:(NSDictionary *)metadata
                       success:(void (^)(SPCustomer *customer))success
                       failure:(void (^)(SPError *))failure {
  NSMutableDictionary *params = [@{
    @"name" : name ?: @"",
    @"website" : website ?: @"",
    @"address" : address ?: @"",
    @"address2" : address2 ?: @"",
    @"city" : city ?: @"",
    @"country" : country ?: @"",
    @"zip" : zip ?: @"",
    @"companyName" : company ?: @"",
    @"email" : email ?: @"",
    @"phone" : phone ?: @"",
    @"state" : state ?: @""
  } mutableCopy];

  NSArray *keysForNullValues = [params allKeysForObject:@""];
  [params removeObjectsForKeys:keysForNullValues];

  if (metadata) {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:metadata
                                                   options:0
                                                     error:&err];
    NSString *metadataStringJson =
        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [params addEntriesFromDictionary:@{@"metadata" : metadataStringJson}];
  }

  if (paymentMethods) {
    NSMutableArray *arr = [NSMutableArray new];
    for (SPPaymentMethod *pm in paymentMethods) {
      [arr addObject:[pm dictionary]];
    }
    [params addEntriesFromDictionary:@{@"paymentMethods" : arr}];
  }

  NSURLSessionDataTask *task =
      [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                  defaultSessionConfiguration]]
          dataTaskWithRequest:[self requestWithMethod:@"POST"
                                               params:params
                                                 path:@"v1/customers"
                                             hostName:_APIHostURL
                                               apiKey:_secretKey]
            completionHandler:^(NSData *_Nullable data,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable error) {
              if (error || [self isResponse:response]) {

                if (failure) {
                  SPError *sperr = [SPError errorWithResponse:data];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    failure(sperr ?: (SPError *)error);
                  });
                }

              } else {

                if (success) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    success([SPCustomer customerWithResponseData:data]);
                  });
                }
              }
            }];

  [task resume];
}

- (void)updateCustomerWithId:(NSString *)custId
                        name:(NSString *)name
                       email:(NSString *)email
                     address:(NSString *)address
                    address2:(NSString *)address2
                        city:(NSString *)city
                     country:(NSString *)country
                       state:(NSString *)state
                         zip:(NSString *)zip
                     company:(NSString *)company
                       phone:(NSString *)phone
                     website:(NSString *)website
              paymentMethods:(NSArray *)paymentMethods
                    metadata:(NSDictionary *)metadata
                     success:(void (^)(SPCustomer *customer))success
                     failure:(void (^)(SPError *))failure {
  NSMutableDictionary *params = [@{
    @"name" : name ?: @"",
    @"website" : website ?: @"",
    @"address" : address ?: @"",
    @"address2" : address2 ?: @"",
    @"city" : city ?: @"",
    @"country" : country ?: @"",
    @"zip" : zip ?: @"",
    @"companyName" : company ?: @"",
    @"email" : email ?: @"",
    @"phone" : phone ?: @"",
    @"state" : state ?: @""
  } mutableCopy];

  NSArray *keysForNullValues = [params allKeysForObject:@""];
  [params removeObjectsForKeys:keysForNullValues];

  if (metadata) {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:metadata
                                                   options:0
                                                     error:&err];
    NSString *metadataStringJson =
        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [params addEntriesFromDictionary:@{@"metadata" : metadataStringJson}];
  }

  if (paymentMethods) {
    NSMutableArray *arr = [NSMutableArray new];
    for (SPPaymentMethod *pm in paymentMethods) {
      [arr addObject:[pm dictionary]];
    }
    [params addEntriesFromDictionary:@{@"paymentMethods" : arr}];
  }

  NSURLSessionDataTask *task = [[NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration
                                   defaultSessionConfiguration]]
      dataTaskWithRequest:
          [self requestWithMethod:@"PUT"
                           params:params
                             path:[NSString stringWithFormat:@"v1/customers/%@",
                                                             custId]
                         hostName:_APIHostURL
                           apiKey:_secretKey]
        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [SPError errorWithResponse:data];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr ?: (SPError *)error);
              });
            }

          } else {

            if (success) {
              dispatch_async(dispatch_get_main_queue(), ^{
                success([SPCustomer customerWithResponseData:data]);
              });
            }
          }
        }];

  [task resume];
}

- (void)retrieveCustomerWithId:(NSString *)custId
                       success:(void (^)(SPCustomer *customer))success
                       failure:(void (^)(SPError *))failure {
  NSURLSessionDataTask *task = [[NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration
                                   defaultSessionConfiguration]]
      dataTaskWithRequest:
          [self requestWithMethod:@"GET"
                           params:@{}
                             path:[NSString stringWithFormat:@"v1/customers/%@",
                                                             custId]
                         hostName:_APIHostURL
                           apiKey:_secretKey]

        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [SPError errorWithResponse:data];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr ?: (SPError *)error);
              });
            }

          } else {

            if (success) {
              dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                id dict = [NSJSONSerialization
                    JSONObjectWithData:data
                               options:NSJSONReadingAllowFragments
                                 error:&error];
                if (error == nil && [dict isKindOfClass:[NSDictionary class]]) {
                  success([SPCustomer customerWithResponseData:data]);
                } else {
                  success(nil);
                }
              });
            }
          }
        }];

  [task resume];
}

- (void)createPaymentMethodWithType:(NSString *)txnType
                            account:(NSString *)account
                            expDate:(NSString *)expDate
                                cvv:(NSString *)cvv
                        accountType:(NSString *)accountType
                            routing:(NSString *)routing
                                pin:(NSString *)pin
                            address:(NSString *)address
                           address2:(NSString *)address2
                               city:(NSString *)city
                            country:(NSString *)country
                              state:(NSString *)state
                                zip:(NSString *)zip
                            company:(NSString *)company
                              email:(NSString *)email
                              phone:(NSString *)phone
                               name:(NSString *)name
                           nickname:(NSString *)nickname
                       verification:(BOOL)verification
                            success:(void (^)(SPPaymentMethod *paymentMethod))
                                        success
                            failure:(void (^)(SPError *))failure {
  NSMutableDictionary *params = [@{
    @"txnType" : txnType ?: @"",
    @"accountNumber" : account ?: @"",
    @"billingAddress" : address ?: @"",
    @"billingAddress2" : address2 ?: @"",
    @"billingCity" : city ?: @"",
    @"billingCountry" : country ?: @"",
    @"billingState" : state ?: @"",
    @"billingZip" : zip ?: @"",
    @"company" : company ?: @"",
    @"phoneNumber" : phone ?: @"",
    @"name" : name ?: @"",
    @"nickname" : nickname ?: @"",
    @"email" : email ?: @"",
    @"verification" : @(verification),
     @"deviceFingerprint" : [self deviceFingerprint]
  } mutableCopy];

  if ([txnType isEqualToString:@"GIFT_CARD"]) {
    [params addEntriesFromDictionary:@{@"pinNumber" : pin ?: @""}];
  }

  if ([txnType isEqualToString:@"CREDIT_CARD"] ||
      [txnType isEqualToString:@"PLDEBIT_CARD"]) {
    [params addEntriesFromDictionary:@{@"expDate" : expDate ?: @""}];
    
  }
    
  if (verification) {
    [params addEntriesFromDictionary:@{@"cvv" : cvv ?: @""}];
  }

  if ([txnType isEqualToString:@"ACH"]) {
    [params addEntriesFromDictionary:@{
      @"bankAccountType" : accountType ?: @"",
      @"routingNumber" : routing ?: @""
    }];
  }

  NSArray *keysForNullValues = [params allKeysForObject:@""];
  [params removeObjectsForKeys:keysForNullValues];

  NSURLSessionDataTask *task =
      [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                  defaultSessionConfiguration]]
          dataTaskWithRequest:[self requestWithMethod:@"POST"
                                               params:params
                                                 path:@"tokens"
                                             hostName:_PanVaulHostURL
                                               apiKey:_publishableKey]
            completionHandler:^(NSData *_Nullable data,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable error) {
              if (error || [self isResponse:response]) {

                if (failure) {
                  SPError *sperr = [SPError errorWithResponse:data];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    failure(sperr ?: (SPError *)error);
                  });
                }

              } else {

                if (success) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    success([SPPaymentMethod tokenWithResponseData:data]);
                  });
                }
              }
            }];

  [task resume];
}

- (void)createChargeWithToken:(NSString *)token
                          cvv:(NSString *)cvv
                      capture:(BOOL)capture
                     currency:(NSString *)currency
                       amount:(NSString *)amount
                    taxAmount:(NSString *)taxAmount
                    taxExempt:(BOOL)taxExempt
                          tip:(NSString *)tip
           surchargeFeeAmount:(NSString *)surchargeFeeAmount
            scheduleIndicator:(NSString *)scheduleIndicator
                  description:(NSString *)description
                        order:(NSDictionary *)order
                      orderId:(NSString *)orderId
                     poNumber:(NSString *)poNumber
                     metadata:(NSDictionary *)metadata
                   descriptor:(NSString *)descriptor
                       txnEnv:(NSString *)txnEnv
                      achType:(NSString *)achType
          credentialIndicator:(NSString *)credentialIndicator
        transactionInitiation:(NSString *)transactionInitiation
               idempotencyKey:(NSString *)idempotencyKey
              needSendReceipt:(BOOL)needSendReceipt
                      success:(void (^)(SPCharge *charge))success
                      failure:(void (^)(SPError *))failure {
  NSMutableDictionary *params = [@{
      @"token" : token ?: @"",
    @"cvv" : cvv ?: @"",
    @"capture" : @(capture),
    @"currency" : currency ?: @"",
    @"amount" : amount ?: @"",
    @"taxAmount" : taxAmount ?: @"",
    @"taxExempt" : @(taxExempt),
    @"tip" : tip ?: @"",
    @"surchargeFeeAmount" : surchargeFeeAmount ?: @"",
    @"scheduleIndicator" : scheduleIndicator ?: @"",
    @"description" : description ?: @"",
    @"orderId" : orderId ?: @"",
    @"poNumber" : poNumber ?: @"",
    @"descriptor" : descriptor ?: @"",
    @"txnEnv" : txnEnv ?: @"",
    @"achType" : achType ?: @"",
    @"credentialIndicator" : credentialIndicator ?: @"",
    @"transactionInitiation" : transactionInitiation ?: @"",
    @"idempotencyKey" : idempotencyKey ?: @"",
    @"needSendReceipt" : @(needSendReceipt),
    @"deviceFingerprint" : [self deviceFingerprint]
  } mutableCopy];

  NSArray *keysForNullValues = [params allKeysForObject:@""];
  [params removeObjectsForKeys:keysForNullValues];

  if (metadata) {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:metadata
                                                   options:0
                                                     error:&err];
    NSString *metadataStringJson =
        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [params addEntriesFromDictionary:@{@"metadata" : metadataStringJson}];
  }

  if (order) {
    [params addEntriesFromDictionary:@{@"order" : order}];
  }

  NSURLSessionDataTask *task =
      [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                  defaultSessionConfiguration]]
          dataTaskWithRequest:[self requestWithMethod:@"POST"
                                               params:params
                                                 path:@"v1/charge"
                                             hostName:_APIHostURL
                                               apiKey:_secretKey]
            completionHandler:^(NSData *_Nullable data,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable error) {
              if (error || [self isResponse:response]) {

                if (failure) {
                  SPError *sperr = [SPError errorWithResponse:data];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    failure(sperr ?: (SPError *)error);
                  });
                }

              } else {

                if (success) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    success([SPCharge chargeWithResponseData:data]);
                  });
                }
              }
            }];

  [task resume];
}

- (void)retrieveChargeWithId:(NSString *)chargeId
                     success:(void (^)(SPCharge *charge))success
                     failure:(void (^)(SPError *))failure {
  NSURLSessionDataTask *task = [[NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration
                                   defaultSessionConfiguration]]
      dataTaskWithRequest:
          [self requestWithMethod:@"GET"
                           params:@{}
                             path:[NSString stringWithFormat:@"v1/charge/%@",
                                                             chargeId]
                         hostName:_APIHostURL
                           apiKey:_secretKey]

        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [SPError errorWithResponse:data];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr ?: (SPError *)error);
              });
            }

          } else {

            if (success) {
              dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                id dict = [NSJSONSerialization
                    JSONObjectWithData:data
                               options:NSJSONReadingAllowFragments
                                 error:&error];
                if (error == nil && [dict isKindOfClass:[NSDictionary class]]) {
                  success([SPCharge chargeWithResponseData:data]);
                } else {
                  success(nil);
                }
              });
            }
          }
        }];

  [task resume];
}

- (void)listChargesWithParams:(NSDictionary *)params
                      success:(void (^)(NSDictionary *dict))success
                      failure:(void (^)(SPError *))failure {
  NSURLSessionDataTask *task = [[NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration
                                   defaultSessionConfiguration]]
      dataTaskWithRequest:[self requestWithMethod:@"GET"
                                           params:params
                                             path:@"v1/charge"
                                         hostName:_APIHostURL
                                           apiKey:_secretKey]

        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [SPError errorWithResponse:data];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr ?: (SPError *)error);
              });
            }

          } else {

            if (success) {
              dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                id dict = [NSJSONSerialization
                    JSONObjectWithData:data
                               options:NSJSONReadingAllowFragments
                                 error:&error];
                if (error == nil && [dict isKindOfClass:[NSDictionary class]]) {
                  success((NSDictionary *)dict);
                } else {
                  success(nil);
                }
              });
            }
          }
        }];

  [task resume];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - <<<Private Methods>>>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isResponse:(NSURLResponse *)response {
  return [(NSHTTPURLResponse *)response statusCode] != 200 &&
         [(NSHTTPURLResponse *)response statusCode] != 201 &&
         [(NSHTTPURLResponse *)response statusCode] != 202;
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                             params:(NSDictionary *)params
                               path:(NSString *)path
                           hostName:(NSString *)hostName
                             apiKey:(NSString *)apiKey {
  NSLog(@"%@", params);

  NSMutableString *pathParams = [NSMutableString new];
  if ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"]) {
  }

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
          initWithURL:[NSURL URLWithString:[NSString
                                               stringWithFormat:@"%@/%@%@",
                                                                hostName, path,
                                                                pathParams]]
          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
      timeoutInterval:k_TimeoutInterval];

  NSData *nsdata = [apiKey dataUsingEncoding:NSUTF8StringEncoding];
  NSString *apiKeyBase64 = [nsdata base64EncodedStringWithOptions:0];

  [request setHTTPMethod:method];

  NSDictionary *headers = @{
    @"API-Version" : [k_APIVersionNumber description],
    @"Content-Type" : @"application/json",
    @"Accept" : @"application/json",
    @"Authorization" : [@"Bearer " stringByAppendingString:apiKeyBase64]
  };
  [request setAllHTTPHeaderFields:headers];
    
  NSLog(@"%@", headers);

  if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
    NSError *err;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0
                                                         error:&err];
    [request setValue:[NSString stringWithFormat:@"%lu",
                                                 (unsigned long)sendData.length]
        forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:sendData];
  }

  // NSLog(@"%@\n%@\n%@\n%@",request.URL, request.HTTPMethod,
  // request.allHTTPHeaderFields,  [[NSString alloc]
  // initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);

  return request;
}

- (NSString*)deviceFingerprint {
    
    NSString *code = NSLocale.currentLocale.languageCode;
    NSString *language = [NSLocale.currentLocale localizedStringForLanguageCode:code];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.appOpenTime];
    NSInteger millis = (NSInteger)round(seconds*1000);
    NSNumber *timeOnPage = @(MAX(millis, 0));
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    double hoursFromGMT = (double)timeZone.secondsFromGMT/(60*60);
    NSString *timeZoneOffset =  [NSString stringWithFormat:@"%.0f", hoursFromGMT];
    
    NSDictionary *dict = @{
        @"fingerprint" : [UIDevice.currentDevice.identifierForVendor  UUIDString],
        @"components" : @[
                @{@"key" : @"user_agent", @"value": [@"SeamlessPay.ios.sdk." stringByAppendingString: [k_APIVersionNumber description]]},
                @{@"key" : @"language", @"value" : language},
                @{@"key" : @"locale_id", @"value" : [[NSLocale currentLocale] localeIdentifier]},
                @{@"key" : @"name", @"value" : UIDevice.currentDevice.name},
                @{@"key" : @"system_name", @"value" : UIDevice.currentDevice.systemName},
                @{@"key" : @"system_version", @"value" : UIDevice.currentDevice.systemVersion},
                @{@"key" : @"model", @"value" :  UIDevice.currentDevice.model},
                @{@"key" : @"localized_model", @"value" : UIDevice.currentDevice.localizedModel},
                @{@"key" : @"user_interface_idiom", @"value" : @(UIDevice.currentDevice.userInterfaceIdiom)},
                @{@"key" : @"time_on_page", @"value" : timeOnPage},
                @{@"key" : @"time_zone_offset", @"value" : timeZoneOffset},
                @{@"key" : @"resolution", @"value": @[
                          @([[UIScreen mainScreen] bounds].size.width),
                          @([[UIScreen mainScreen] bounds].size.height)
                          ]}
        ]
    };
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *nsdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [nsdata base64EncodedStringWithOptions:0];
}

@end
