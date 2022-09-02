/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPAPIClient.h"

static const NSString *k_APIHostURL;
static const NSString *k_APIHostURLLive = @"https://api.seamlesspay.io";
static const NSString *k_APIHostURLSandbox = @"https://api.seamlesspay.io";
//static const NSString *k_PanVaultHostURLLive = @"https://pan-vault.seamlesspay.com";
//static const NSString *k_PanVaultHostURLSandbox = @"https://sandbox-pan-vault.seamlesspay.com";

static const NSString *k_PanVaultHostURLLive = @"https://pan-vault.l1.seamlesspay.io";
static const NSString *k_PanVaultHostURLSandbox = @"https://pan-vault.l1.seamlesspay.io";


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

- (void)setSecretKey:(NSString *)secretKey
      publishableKey:(NSString *)publishableKey
         apiEndpoint:(NSString *)APIEndpoint
    panVaultEndpoint:(NSString *)PANVaultEndpoint {

    _secretKey = [secretKey copy];
    _publishableKey = [publishableKey copy];
    _APIHostURL = [APIEndpoint copy];
    _PanVaulHostURL = [PANVaultEndpoint copy];
    
  self.appOpenTime = [NSDate date];
}

- (void)setSubMerchantAccountID:(NSString *_Nullable)subMerchantAccountID {
    _subMerchantAccountID = subMerchantAccountID;
}

- (void)_customerWithName:(NSString *)name
                    email:(NSString *)email
                  address:(SPAddress *)address
              companyName:(NSString *)companyName
                    notes:(NSString *)notes
                    phone:(NSString *)phone
                  website:(NSString *)website
           paymentMethods:(NSArray *)paymentMethods
                 metadata:(NSString *)metadata
                   method:(NSString *)method
                     path:(NSString *)path
                  success:(void (^)(SPCustomer *customer))success
                  failure:(void (^)(SPError *))failure {
    
    NSMutableDictionary *params = [@{
        @"name" : name ?: @"",
        @"website" : website ?: @"",
        @"address" : address && [address dictionary] ? [address dictionary] : @"",
        @"companyName" : companyName ?: @"",
        @"description" : notes ?: @"",
        @"email" : email ?: @"",
        @"phone" : phone ?: @"",
        @"metadata" : metadata ?: @"metadata",
    } mutableCopy];
    
    NSArray *keysForNullValues = [params allKeysForObject:@""];
    [params removeObjectsForKeys:keysForNullValues];
    
    
    if (paymentMethods) {
        NSMutableArray *arr = [NSMutableArray new];
        for (SPPaymentMethod *pm in paymentMethods) {
            [arr addObject:@{@"token" : pm.token}];
        }
        [params addEntriesFromDictionary:@{@"paymentMethods" : arr}];
    }
    
    NSURLSessionDataTask *task =
    [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                             defaultSessionConfiguration]]
     dataTaskWithRequest:[self requestWithMethod:method
                                          params:params
                                            path:path
                                        hostName:_APIHostURL
                                          apiKey:_secretKey
                                      apiVersion:@"v2020" ]
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


- (void)createCustomerWithName:(NSString *)name
                         email:(NSString *)email
                       address:(SPAddress *)address                      
                   companyName:(NSString *)companyName
                         notes:(NSString *)notes
                         phone:(NSString *)phone
                       website:(NSString *)website
                paymentMethods:(NSArray *)paymentMethods
                      metadata:(NSString *)metadata
                       success:(void (^)(SPCustomer *customer))success
                       failure:(void (^)(SPError *))failure {
    
    [self _customerWithName:name
                      email:email
                    address:address
                companyName:companyName
                      notes:notes
                      phone:phone
                    website:website
             paymentMethods:paymentMethods
                   metadata:metadata
                     method:@"POST"
                       path:@"customers"
                    success:success
                    failure:failure];
}

- (void)updateCustomerWithId:(NSString *)customerId
                          name:(NSString *)name
                         email:(NSString *)email
                       address:(SPAddress *)address
                   companyName:(NSString *)companyName
                         notes:(NSString *)notes
                         phone:(NSString *)phone
                       website:(NSString *)website
                paymentMethods:(NSArray *)paymentMethods
                      metadata:(NSString *)metadata
                       success:(void (^)(SPCustomer *customer))success
                       failure:(void (^)(SPError *))failure {
    
    [self _customerWithName:name
                      email:email
                    address:address
                companyName:companyName
                      notes:notes
                      phone:phone
                    website:website
             paymentMethods:paymentMethods
                   metadata:metadata
                     method:@"PUT"
                       path:[NSString stringWithFormat:@"customers/%@", customerId]
                    success:success
                    failure:failure];
}

- (void)retrieveCustomerWithId:(NSString *)customerId
                       success:(void (^)(SPCustomer *customer))success
                       failure:(void (^)(SPError *))failure {
  NSURLSessionDataTask *task = [[NSURLSession
      sessionWithConfiguration:[NSURLSessionConfiguration
                                   defaultSessionConfiguration]]
      dataTaskWithRequest:
          [self requestWithMethod:@"GET"
                           params:@{}
                             path:[NSString stringWithFormat:@"customers/%@",
                                   customerId]
                         hostName:_APIHostURL
                           apiKey:_secretKey
                           apiVersion:@"v2020"]

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

- (void)createTokenWithPayment:(nonnull PKPayment *)payment
            merchantIdentifier:(NSString *)merchantIdentifier
                       success:(void(^)(SPPaymentMethod * paymentMethod))success
                       failure:(void(^)(SPError *))failure {
    
    
    NSCAssert(payment != nil, @"Cannot create a token with a nil payment.");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
 
    
    params[@"appleToken"] = paymentData;
    params[@"merchantIdentifier"] = merchantIdentifier;
    paymentData[@"paymentData"] = [NSJSONSerialization JSONObjectWithData:payment.token.paymentData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    paymentData[@"transactionIdentifier"] = payment.token.transactionIdentifier;
    
    NSString *type;
    switch (payment.token.paymentMethod.type) {
        case PKPaymentMethodTypeDebit:
            type = @"debit";
            params[@"paymentType"] = @"pldebit_card";
            break;
        case PKPaymentMethodTypeCredit:
            type = @"credit";
            params[@"paymentType"] = @"credit_card";
            break;
            
        default:
            type = @"unknown";
            params[@"paymentType"] = @"unknown";
            break;
    }
 
    
    paymentData[@"paymentMethod"] = @{
        @"displayName" : payment.token.paymentMethod.displayName,
        @"network": payment.token.paymentMethod.network,
        @"type" : type};
       
    if (payment.billingContact) {
        
        params[@"name"] = [NSString stringWithFormat:@"%@ %@", payment.billingContact.name.givenName?:@"", payment.billingContact.name.familyName?:@""];
        
        if (payment.billingContact.phoneNumber) {
            params[@"phoneNumber"] = [NSString stringWithFormat:@"%@", payment.billingContact.phoneNumber.stringValue];
        } else if (payment.shippingContact && payment.shippingContact.phoneNumber) {
            params[@"phoneNumber"] = [NSString stringWithFormat:@"%@", payment.shippingContact.phoneNumber.stringValue];
        }
        
        if (payment.billingContact.emailAddress) {
            params[@"email"] = [NSString stringWithFormat:@"%@", payment.billingContact.emailAddress];
        } else if (payment.shippingContact && payment.shippingContact.emailAddress) {
            params[@"email"] = [NSString stringWithFormat:@"%@", payment.shippingContact.emailAddress];
        }
 
        
        NSMutableDictionary *billingAddress = [NSMutableDictionary dictionary];
        billingAddress[@"line1"] = [NSString stringWithFormat:@"%@", payment.billingContact.postalAddress.street];
        billingAddress[@"line2"] = @"";
        billingAddress[@"city"] = [NSString stringWithFormat:@"%@", payment.billingContact.postalAddress.city];
        billingAddress[@"country"] = [NSString stringWithFormat:@"%@", payment.billingContact.postalAddress.ISOCountryCode];
        
        if ([billingAddress[@"country"] isEqual:@"US"]) {
            NSString * scode = [self _USStateCodeWithName:payment.billingContact.postalAddress.state];
            if (scode != nil) {
                billingAddress[@"state"] = [NSString stringWithFormat:@"%@", scode];
            }
        } else {
            billingAddress[@"state"] = [NSString stringWithFormat:@"%@", payment.billingContact.postalAddress.state];
        }
        
        billingAddress[@"postalCode"] = [NSString stringWithFormat:@"%@", payment.billingContact.postalAddress.postalCode];
        params[@"billingAddress"] = billingAddress;
        
    }
   
    NSArray *keysForNullValues = [params allKeysForObject:@""];
    [params removeObjectsForKeys:keysForNullValues];
    
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]
                                  dataTaskWithRequest:[self requestWithMethod: @"POST"
                                                                       params: params
                                                                         path: @"tokens"
                                                                     hostName:_PanVaulHostURL
                                                                       apiKey:_publishableKey
                                                                    apiVersion:@"v2020"]
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || [self isResponse:response]) {
            
            if (failure) {
                SPError *sperr = [SPError errorWithResponse:data];
                NSLog(@"%@", sperr);
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure (sperr ? : (SPError*)error);
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

- (void)createPaymentMethodWithPaymentType:(NSString *)paymentType
                            account:(NSString *)account
                            expDate:(NSString *)expDate
                                cvv:(NSString *)cvv
                        accountType:(NSString *)accountType
                            routing:(NSString *)routing
                                pin:(NSString *)pin
                    billingAddress:(SPAddress *)billingAddress
                billingCompanyName:(NSString *)billingCompany
                      accountEmail:(NSString *)accountEmail
                       phoneNumber:(NSString *)phoneNumber
                               name:(NSString *)name
                           customer:(SPCustomer *)customer
                            success:(void (^)(SPPaymentMethod *paymentMethod))
                                        success
                            failure:(void (^)(SPError *))failure {
    
       
  NSMutableDictionary *params = [@{
    @"paymentType" : paymentType ?: @"",
    @"accountNumber" : account ?: @"",
    @"billingAddress" : [billingAddress dictionary] ? [billingAddress dictionary] : @"",
    @"company" : billingCompany ?: @"",
    @"email" : accountEmail ?: @"",
    @"name" : name ?: @"",
    @"phoneNumber" : phoneNumber ?: @"",
    @"customer" : [customer dictionary] ? [customer dictionary] : @"",
    @"deviceFingerprint" : [self deviceFingerprint]
  } mutableCopy];

  if ([paymentType isEqualToString:@"gift_card"]) {
    [params addEntriesFromDictionary:@{@"pinNumber" : pin ?: @""}];
  }

  if ([paymentType isEqualToString:@"credit_card"] ||
      [paymentType isEqualToString:@"pldebit_card"]) {
    [params addEntriesFromDictionary:@{@"expDate" : expDate ?: @""}];
    
  }
    
    if ([paymentType isEqualToString:@"credit_card"]) {
      [params addEntriesFromDictionary:@{@"cvv" : cvv ?: @""}];
      
    }
    
  if ([paymentType isEqualToString:@"ach"]) {
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
                                               apiKey:_publishableKey
                                           apiVersion:@"v2020"]
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
                  description:(NSString *)description
                        order:(NSDictionary *)order
                      orderId:(NSString *)orderId
                     poNumber:(NSString *)poNumber
                     metadata:(NSString *)metadata
                   descriptor:(NSString *)descriptor
                    entryType:(NSString *)entryType
               idempotencyKey:(NSString *)idempotencyKey
     digitalWalletProgramType:(NSString *)digitalWalletProgramType
                      success:(void (^)(SPCharge *charge))success
                      failure:(void (^)(SPError *))failure {
    
  NSMutableDictionary *params = [@{
    @"token" : token ?: @"",//
    @"cvv" : cvv ?: @"",//
    @"capture" : @(capture),//
    @"currency" : currency ?: @"",//
    @"amount" : amount ?: @"",//
    @"taxAmount" : taxAmount ?: @"",//
    @"taxExempt" : @(taxExempt),//
    @"tip" : tip ?: @"",//
    @"surchargeFeeAmount" : surchargeFeeAmount ?: @"",//
    @"description" : description ?: @"",//
    @"orderID" : orderId ?: @"",//
    @"poNumber" : poNumber ?: @"",//
    @"descriptor" : descriptor ?: @"",//
    @"idempotencyKey" : idempotencyKey ?: @"",//
    @"digitalWalletProgramType" : digitalWalletProgramType ?: @"",//
    @"entryType" : entryType ?: @"",//
    @"metadata" : metadata ?: @"",//
    @"order" : order ?: @"",//
    @"deviceFingerprint" : [self deviceFingerprint]
  } mutableCopy];
    
  NSArray *keysForNullValues = [params allKeysForObject:@""];
  [params removeObjectsForKeys:keysForNullValues];

  NSURLSessionDataTask *task =
      [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                  defaultSessionConfiguration]]
          dataTaskWithRequest:[self requestWithMethod:@"POST"
                                               params:params
                                                 path:@"charges"
                                             hostName:_APIHostURL
                                               apiKey:_secretKey
                                           apiVersion:@"v2020"]
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
                             path:[NSString stringWithFormat:@"charges/%@",
                                                             chargeId]
                         hostName:_APIHostURL
                           apiKey:_secretKey
                       apiVersion:@"v2020"]

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
                                             path:@"charges"
                                         hostName:_APIHostURL
                                           apiKey:_secretKey
                                       apiVersion:@"v2020"]

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
    
    return [self requestWithMethod:(NSString *)method
                            params:(NSDictionary *)params
                              path:(NSString *)path
                          hostName:(NSString *)hostName
                            apiKey:(NSString *)apiKey
                        apiVersion:(NSString *) [k_APIVersionNumber description]];
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                             params:(NSDictionary *)params
                               path:(NSString *)path
                           hostName:(NSString *)hostName
                             apiKey:(NSString *)apiKey
                         apiVersion:(NSString *)apiVersion {
    
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

  NSMutableDictionary *headers = [@{
    @"API-Version" : apiVersion,
    @"Content-Type" : @"application/json",
    @"Accept" : @"application/json",
    @"Authorization" : [@"Bearer " stringByAppendingString:apiKeyBase64]
  } mutableCopy];
    
    if (_subMerchantAccountID) {
        headers[@"SeamlessPay-Account"] = _subMerchantAccountID;
    }
    
  [request setAllHTTPHeaderFields:headers];
    
  NSLog(@"Headers: %@", headers);
  NSLog(@"Body: %@", params);

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

   NSLog(@"%@\n%@\n%@\n%@",request.URL, request.HTTPMethod,
   request.allHTTPHeaderFields,  [[NSString alloc]
   initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);

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
                @{@"key" : @"user_agent", @"value": [@"ios sdk v" stringByAppendingString: [k_APIVersionNumber description]]},
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

- (nullable NSString *)_USStateCodeWithName:(NSString*)name {
    
    NSString *trimmedName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSDictionary *ussates = @{
        @"AL":@"ALABAMA",
        @"NV":@"NEVADA",
        @"AK":@"ALASKA",
        @"NH":@"NEW HAMPSHIRE",
        @"AS":@"AMERICAN SAMOA",
        @"NJ":@"NEW JERSEY",
        @"AZ":@"ARIZONA",
        @"NM":@"NEW MEXICO",
        @"AR":@"ARKANSAS",
        @"NY":@"NEW YORK",
        @"CA":@"CALIFORNIA",
        @"NC":@"NORTH CAROLINA",
        @"CO":@"COLORADO",
        @"ND":@"NORTH DAKOTA",
        @"CT":@"CONNECTICUT",
        @"OH":@"OHIO",
        @"DE":@"DELAWARE",
        @"OK":@"OKLAHOMA",
        @"DC":@"DISTRICT OF COLUMBIA",
        @"OR":@"OREGON",
        @"FL":@"FLORIDA",
        @"PA":@"PENNSYLVANIA",
        @"GA":@"GEORGIA",
        @"MY":@"MILITARY ID",
        @"GU":@"GUAM",
        @"RI":@"RHODE ISLAND",
        @"PR":@"PUERTO RICO",
        @"SC":@"SOUTH CAROLINA",
        @"HI":@"HAWAII",
        @"SD":@"SOUTH DAKOTA",
        @"ID":@"IDAHO",
        @"TN":@"TENNESSEE",
        @"IL":@"ILLINOIS",
        @"TX":@"TEXAS",
        @"IN":@"INDIANA",
        @"UT":@"UTAH",
        @"IA":@"IOWA",
        @"VT":@"VERMONT",
        @"KS":@"KANSAS",
        @"VA":@"VIRGINIA",
        @"KY":@"KENTUCKY",
        @"VI":@"VIRGIN ISLANDS",
        @"LA":@"LOUISIANA",
        @"WA":@"WASHINGTON",
        @"ME":@"MAINE",
        @"WV":@"WEST VIRGINIA",
        @"MD":@"MARYLAND",
        @"WI":@"WISCONSIN",
        @"MA":@"MASSACHUSETTS",
        @"WY":@"WYOMING",
        @"MH":@"MARSHALL ISLANDS",
        @"AB":@"ALBERTA",
        @"MI":@"MICHIGAN",
        @"BC":@"BRITISH COLUMBIA",
        @"MN":@"MINNESOTA",
        @"MB":@"MANITOBA",
        @"NB":@"NEW BRUNSWICK",
        @"MP":@"NORTHERN MARIANA",
        @"MS":@"ISLANDS MISSISSIPPI",
        @"NF":@"NEWFOUNDLAND",
        @"MO":@"MISSOURI",
        @"NS":@"NOVA SCOTIA",
        @"MT":@"MONTANA",
        @"NT":@"NORTHWEST TERRITORIES",
        @"NE":@"NEBRASKA",
        @"ON":@"ONTARIO",
        @"PE":@"PRINCE EDWARD",
        @"SK":@"SASKATCHEWAN",
        @"PQ":@"QUEBEC",
        @"YT":@"YUKON"
    };
    
    NSString *sname = nil;
    
    if (name.length == 2) {
        for (NSString *key in ussates) {
            if ([key isEqual:trimmedName.uppercaseString]) {
                return key;
            }
        }
        return nil;
    }
    
    for (NSString *key in ussates) {
        sname = ussates[key];
        if ([sname isEqual:trimmedName.uppercaseString]) {
            return key;
        }
    }
    
    return nil;
}

@end
