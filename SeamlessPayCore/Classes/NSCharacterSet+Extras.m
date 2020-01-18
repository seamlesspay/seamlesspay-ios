//
//  NSCharacterSet+Extras.m
//

#import "NSCharacterSet+Extras.h"

@implementation NSCharacterSet (Extras)

+ (instancetype)sp_asciiDigitCharacterSet {
    static NSCharacterSet *cs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs = [self characterSetWithCharactersInString:@"0123456789"];
    });
    return cs;
}

+ (instancetype)sp_invertedAsciiDigitCharacterSet {
    static NSCharacterSet *cs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs = [[self sp_asciiDigitCharacterSet] invertedSet];
    });
    return cs;
}

@end

void linkNSCharacterSetCategory(void){}
