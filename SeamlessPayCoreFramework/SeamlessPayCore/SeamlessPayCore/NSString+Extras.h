//
//  NSString+Extras.h
//  
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

@interface NSString (Extras)

- (NSString *)sp_safeSubstringToIndex:(NSUInteger)index;
- (NSString *)sp_safeSubstringFromIndex:(NSUInteger)index;
- (NSString *)sp_reversedString;
- (NSString *)sp_stringByRemovingSuffix:(NSString *)suffix;

@end

void linkNSStringCategory(void);
