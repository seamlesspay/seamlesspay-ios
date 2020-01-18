//
//  NSString+Extras.h
//  
//

#import <Foundation/Foundation.h>

@interface NSString (Extras)

- (NSString *)sp_safeSubstringToIndex:(NSUInteger)index;
- (NSString *)sp_safeSubstringFromIndex:(NSUInteger)index;
- (NSString *)sp_reversedString;
- (NSString *)sp_stringByRemovingSuffix:(NSString *)suffix;

@end

void linkNSStringCategory(void);
