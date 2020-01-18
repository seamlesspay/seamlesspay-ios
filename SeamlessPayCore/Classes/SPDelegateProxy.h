//
//  SPDelegateProxy.h
//

#import <Foundation/Foundation.h>

@interface SPDelegateProxy<__covariant DelegateType:NSObject<NSObject> *> : NSObject

@property (nonatomic, weak) DelegateType delegate;
- (instancetype)init;

@end
