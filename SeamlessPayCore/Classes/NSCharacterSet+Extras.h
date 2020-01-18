//
//  NSCharacterSet+Extras.h
//
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (Extras)

+ (instancetype)sp_asciiDigitCharacterSet;
+ (instancetype)sp_invertedAsciiDigitCharacterSet;


@end

void linkNSCharacterSetCategory(void);
