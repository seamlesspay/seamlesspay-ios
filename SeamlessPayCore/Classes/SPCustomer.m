//
//  SPCustomer.m
//  SeamlessPayCore
//


#import "SPCustomer.h"

@implementation SPCustomer

+ (instancetype)customerWithResponseData:(NSData * )data
{
    return [[SPCustomer alloc] initWithResponseData:data];
}


- (instancetype)initWithResponseData:(NSData * )data
{
    self = [super init];
    if (self) {
        
        NSError *error = nil;
        id dict = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingAllowFragments
                                                   error:&error];
        
        if (error == nil && [dict isKindOfClass:[NSDictionary class]]) {

            NSMutableDictionary *obj = [dict mutableCopy];
            NSArray *keysForNullValues = [obj allKeysForObject:[NSNull null]];
            [obj removeObjectsForKeys:keysForNullValues];
            
            NSLog(@"%@",obj);
            
            _custId = [obj[@"id"] copy];
            _name = [obj[@"name"] copy];
            _email = [obj[@"email"] copy];
            _address = [obj[@"address"] copy];
            _address2 = [obj[@"address2"] copy];
            _city = [obj[@"city"] copy];
            _companyName = [obj[@"companyName"] copy];
            _country = [obj[@"country"] copy];
            _state = [obj[@"state"] copy];
            _phone = [obj[@"phone"] copy];
            _zip = [obj[@"zip"] copy];
            _website = [obj[@"website"] copy];
            _metadata = [obj[@"metadata"] copy];
            
            if (error == nil && [obj[@"paymentMethods"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *arr = [NSMutableArray new];
                for (NSDictionary *dict in obj[@"paymentMethods"]) {
                    SPPaymentMethod *pm = [[SPPaymentMethod alloc] initWithDictionary:dict];
                    [arr addObject:pm];
                }
                _paymentMethods = arr;
             }
        }
    }
    return self;
}

- (NSDictionary*)dictionary
{
    NSMutableArray *arr = [NSMutableArray new];
    if (_paymentMethods) {
        for (SPPaymentMethod *pm in _paymentMethods) {
            [arr addObject:[pm dictionary]];
        }
    }
    
    return @{
        @"id" : _custId?:@"",
        @"name" : _name?:@"",
        @"email" : _email?:@"",
        @"address" : _address?:@"",
        @"address2" : _address2?:@"",
        @"city" : _city?:@"",
        @"state" : _state?:@"",
        @"zip" : _zip?:@"",
        @"country" : _country?:@"",
        @"phone" : _phone?:@"",
        @"companyName" : _companyName?:@"",
        @"website" : _website?:@"",
        @"metadata" : _metadata?:@"",
        @"paymentMethods" : arr
    };
}
@end
