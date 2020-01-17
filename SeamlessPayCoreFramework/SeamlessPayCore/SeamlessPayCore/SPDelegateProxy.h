//
//  SPDelegateProxy.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

@interface SPDelegateProxy<__covariant DelegateType:NSObject<NSObject> *> : NSObject

@property (nonatomic, weak) DelegateType delegate;
- (instancetype)init;

@end
