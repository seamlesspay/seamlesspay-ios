//
//  SPEmailAddressValidator.h
//

#import <Foundation/Foundation.h>

@interface SPEmailAddressValidator : NSObject

+ (BOOL)stringIsValidPartialEmailAddress:(nullable NSString *)string;
+ (BOOL)stringIsValidEmailAddress:(nullable NSString *)string;

@end
