/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@import Sentry;

#import "SPAPIClient.h"
#import <SeamlessPayCore/SeamlessPayCore-Swift.h>

NSString * const k_APIVersion = @"v2020";
static const NSTimeInterval k_TimeoutInterval = 15.0;

static SPAPIClient *sharedInstance = nil;

// MARK: - Interface
@interface SPAPIClient () {
  NSString *_APIHostURL;
  NSString *_PanVaultHostURL;
  SPEnvironment _environment;
  SPSentryClient *_sentryClient;
}

@property (nonatomic) NSDate *appOpenTime;
@end

// MARK: - Implementation
@implementation SPAPIClient

+ (instancetype)getSharedInstance {
  if (!sharedInstance) {
    sharedInstance = [[super allocWithZone:NULL] init];
  }
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _sentryClient = [SPSentryClient make];
  }
  return self;
}

- (void)setSecretKey:(NSString *)secretKey
      publishableKey:(NSString *)publishableKey
         environment:(SPEnvironment)environment {
  _APIHostURL = [self hostURLForEnvironment:environment];
  _PanVaultHostURL = [self panVaultURLForEnvironment:environment];
  _secretKey = [secretKey ?: publishableKey copy];
  _publishableKey = [publishableKey copy];
  _environment = environment;

  [self startSentryForEnvironment:environment];

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
                                      apiVersion:k_APIVersion]
     completionHandler:^(NSData *_Nullable data,
                         NSURLResponse *_Nullable response,
                         NSError *_Nullable error) {
        if (error || [self isResponse:response]) {
            if (failure) {
                SPError *sperr = [self errorWithData:data error:error];

                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(sperr);
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
                           apiVersion:k_APIVersion]

        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [self errorWithData:data error:error];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr);
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

- (void)tokenizeWithPaymentType:(SPPaymentType)paymentType
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
                        success:(void (^)(SPPaymentMethod *paymentMethod))success
                        failure:(void (^)(SPError *))failure {
    
  NSString *paymentTypeString = [self valueForPaymentType:paymentType];
  NSMutableDictionary *params = [@{
    @"paymentType" : paymentTypeString ?: @"",
    @"accountNumber" : account ?: @"",
    @"billingAddress" : [billingAddress dictionary] ? [billingAddress dictionary] : @"",
    @"company" : billingCompany ?: @"",
    @"email" : accountEmail ?: @"",
    @"name" : name ?: @"",
    @"phoneNumber" : phoneNumber ?: @"",
    @"customer" : [customer dictionary] ? [customer dictionary] : @"",
    @"deviceFingerprint" : [self deviceFingerprint]
  } mutableCopy];

  if (paymentType == SPPaymentTypeGiftCard) {
    [params addEntriesFromDictionary:@{@"pinNumber" : pin ?: @""}];
  }

  if (paymentType == SPPaymentTypeCreditCard || paymentType == SPPaymentTypePlDebitCard) {
    [params addEntriesFromDictionary:@{@"expDate" : expDate ?: @""}];
    
  }
    
    if (paymentType == SPPaymentTypeCreditCard) {
      [params addEntriesFromDictionary:@{@"cvv" : cvv ?: @""}];
      
    }
  if (paymentType == SPPaymentTypeAch) {
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
                                             hostName:_PanVaultHostURL
                                               apiKey:_publishableKey
                                           apiVersion:k_APIVersion]
            completionHandler:^(NSData *_Nullable data,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable error) {
              if (error || [self isResponse:response]) {

                if (failure) {
                  SPError *sperr = [self errorWithData:data error:error];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    failure(sperr);
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
                                           apiVersion:k_APIVersion]
            completionHandler:^(NSData *_Nullable data,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable error) {
              if (error || [self isResponse:response]) {

                if (failure) {
                  SPError *sperr = [self errorWithData:data error:error];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    failure(sperr);
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
                       apiVersion:k_APIVersion]

        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [self errorWithData:data error:error];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr);
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
                                       apiVersion:k_APIVersion]

        completionHandler:^(NSData *_Nullable data,
                            NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error || [self isResponse:response]) {

            if (failure) {
              SPError *sperr = [self errorWithData:data error:error];
              dispatch_async(dispatch_get_main_queue(), ^{
                failure(sperr);
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

- (NSString *)valueForPaymentType:(SPPaymentType)paymentType {
  switch (paymentType) {
    case SPPaymentTypeAch:
      return @"ach";
    case SPPaymentTypeCreditCard:
      return @"credit_card";
    case SPPaymentTypeGiftCard:
      return @"gift_card";
    case SPPaymentTypePlDebitCard:
      return @"pldebit_card";
  }

  NSAssert(NO, @"Unexpected SPSPPaymentTypes");
  return @"";
}

- (NSString *)panVaultURLForEnvironment:(SPEnvironment)environment {
  switch (environment) {
    case SPEnvironmentProduction:
      return @"https://pan-vault.seamlesspay.com";
    case SPEnvironmentSandbox:
      return @"https://sandbox-pan-vault.seamlesspay.com";
    case SPEnvironmentStaging:
      return @"https://pan-vault.seamlesspay.dev";
    case SPEnvironmentQAT:
      return @"https://pan-vault.seamlesspay.io";
  }

  NSAssert(NO, @"Unexpected SPEnvironment");
  return @"";
}

- (NSString *)hostURLForEnvironment:(SPEnvironment)environment {
  switch (environment) {
    case SPEnvironmentProduction:
      return @"https://api.seamlesspay.com";
    case SPEnvironmentSandbox:
      return @"https://sandbox.seamlesspay.com";
    case SPEnvironmentStaging:
      return @"https://api.seamlesspay.dev";
    case SPEnvironmentQAT:
      return @"https://api.seamlesspay.io";
  }

  NSAssert(NO, @"Unexpected SPEnvironment");
  return @"";
}

- (SPError *)errorWithData:(NSData *_Nullable)data
                     error:(NSError *_Nullable)error {
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
                        apiVersion:(NSString *) k_APIVersion];
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
    @"Authorization" : [@"Bearer " stringByAppendingString:apiKeyBase64],
    @"User-Agent" : @"seamlesspay_ios"
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
                @{@"key" : @"user_agent", @"value": [@"ios sdk v" stringByAppendingString: k_APIVersion]},
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

// MARK: Sentry
- (void)startSentryForEnvironment:(SPEnvironment)environment {
  dispatch_async(dispatch_get_main_queue(), ^{
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = @"https://3936eb5f56b34be7baf5eef81e5652ba@o4504125304209408.ingest.sentry.io/https://o4504125304209408.ingest.sentry.io/api/4505325448921088/envelope/";
      options.enableTracing = YES;
      options.tracesSampleRate = @1.0;

      switch (environment) {
        case SPEnvironmentProduction:
        case SPEnvironmentSandbox:
          options.debug = NO;
          break;
        case SPEnvironmentStaging:
        case SPEnvironmentQAT:
          options.debug = YES;
          break;
      }

      SentryHttpStatusCodeRange *httpStatusCodeRange = [[SentryHttpStatusCodeRange alloc] initWithMin:400
                                                                                                  max:599];
      options.failedRequestStatusCodes = @[ httpStatusCodeRange ];
      options.failedRequestTargets = @[ [self hostURLForEnvironment:environment],
                                        [self panVaultURLForEnvironment:environment] ];
    }];
  });
}

@end

