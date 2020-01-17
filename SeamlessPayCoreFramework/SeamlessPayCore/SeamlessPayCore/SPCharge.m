//
//  SPCharge.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPCharge.h"

@implementation SPCharge

+ (instancetype)chargeWithResponseData:(NSData * )data
{
    return [[SPCharge alloc] initWithResponseData:data];
}


- (instancetype)initWithResponseData:(NSData * )data
{
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
            
            NSLog(@"%@",obj);
            
            _chargeId = [dict[@"id"] copy];
            _method = [dict[@"method"] copy];
            _amount = [dict[@"amount"] copy];
            _tip = [dict[@"tip"] copy];
            _surchargeFeeAmount = [dict[@"surchargeFeeAmount"] copy];
            _order = [dict[@"order"] copy];
            _currency = [dict[@"currency"] copy];
            _cardBrand = [dict[@"cardBrand"] copy];
            _cardType = [dict[@"cardType"] copy];
            _lastFour = [dict[@"lastFour"] copy];
            _token = [dict[@"token"] copy];
            _txnDate = [dict[@"txnDate"] copy];
            _status = [dict[@"status"] copy];
            _statusCode = [dict[@"statusCode"] copy];
            _statusDescription = [dict[@"statusDescription"] copy];
            _avsResult = [dict[@"avsResult"] copy];
            _avsMessage = [dict[@"avsMessage"] copy];
            _cvvResult = [dict[@"cvvResult"] copy];
            _ipAddress = [dict[@"ipAddress"] copy];
            _authCode = [dict[@"authCode"] copy];
            _batch = [dict[@"batch"] copy];
            _adjustments = [dict[@"adjustments"] copy];
            _businessCard = [dict[@"businessCard"] boolValue];
        }
    }
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        
        NSMutableDictionary *dict = [dictionary mutableCopy];
        NSArray *keysForNullValues = [dict allKeysForObject:[NSNull null]];
        [dict removeObjectsForKeys:keysForNullValues];
        
        _chargeId = [dict[@"id"] copy];
        _method = [dict[@"method"] copy];
        _amount = [dict[@"amount"] copy];
        _tip = [dict[@"tip"] copy];
        _surchargeFeeAmount = [dict[@"surchargeFeeAmount"] copy];
        _order = [dict[@"order"] copy];
        _currency = [dict[@"currency"] copy];
        _cardBrand = [dict[@"cardBrand"] copy];
        _cardType = [dict[@"cardType"] copy];
        _lastFour = [dict[@"lastFour"] copy];
        _token = [dict[@"token"] copy];
        _txnDate = [dict[@"txnDate"] copy];
        _status = [dict[@"status"] copy];
        _statusCode = [dict[@"statusCode"] copy];
        _statusDescription = [dict[@"statusDescription"] copy];
        _avsResult = [dict[@"avsResult"] copy];
        _avsMessage = [dict[@"avsMessage"] copy];
        _cvvResult = [dict[@"cvvResult"] copy];
        _ipAddress = [dict[@"ipAddress"] copy];
        _authCode = [dict[@"authCode"] copy];
        _batch = [dict[@"batch"] copy];
        _adjustments = [dict[@"adjustments"] copy];
        _businessCard = [dict[@"businessCard"] boolValue];
    }
    return self;
}




@end
