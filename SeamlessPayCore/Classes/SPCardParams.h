//
//  SPCardParams.h
//

#import <Foundation/Foundation.h>

#import "SPFormEncodable.h"
#if TARGET_OS_IPHONE
#import "SPAddress.h"
#endif

@interface SPCardParams : NSObject


@property (nonatomic, copy, nullable) NSString *number;

- (nullable NSString *)last4;

@property (nonatomic) NSUInteger expMonth;

@property (nonatomic) NSUInteger expYear;

@property (nonatomic, copy, nullable) NSString *cvc;

@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, strong, nonnull) SPAddress *address;

@property (nonatomic, copy, nullable) NSString *currency;



@end
