//
//  SPDelegateProxy.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPDelegateProxy.h"

@implementation SPDelegateProxy

- (instancetype)init {
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [super respondsToSelector:selector] || [_delegate respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    if ([self respondsToSelector:selector]) {
        return self;
    }
    if ([_delegate respondsToSelector:selector]) {
        return _delegate;
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [super methodSignatureForSelector:selector] ?: [_delegate methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([_delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:_delegate];
    }
}

@end
