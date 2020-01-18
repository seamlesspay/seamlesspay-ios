
//
//  SPPhoneNumberValidator.m
//

#import "SPPhoneNumberValidator.h"


#import "NSString+Extras.h"
#import "SPCardValidator.h"
@implementation SPPhoneNumberValidator

+ (NSString *)countryCodeOrCurrentLocaleCountryFromString:(nullable NSString *)nillableCode {
    NSString *countryCode = nillableCode;
    if (!countryCode) {
        countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
    }
    return countryCode;
}
                                                           
+ (BOOL)stringIsValidPartialPhoneNumber:(NSString *)string {
    return [self stringIsValidPartialPhoneNumber:string forCountryCode:nil];
}

+ (BOOL)stringIsValidPhoneNumber:(NSString *)string {
    if (!string) {
        return NO;
    }
    return [self stringIsValidPhoneNumber:string forCountryCode:nil];
}

+ (BOOL)stringIsValidPartialPhoneNumber:(NSString *)string
                         forCountryCode:(nullable NSString *)nillableCode {
    NSString *countryCode = [self countryCodeOrCurrentLocaleCountryFromString:nillableCode];
    
    if ([countryCode isEqualToString:@"US"]) {
        return [SPCardValidator sanitizedNumericStringForString:string].length <= 10;
    } else {
        return YES;
    }
}

+ (BOOL)stringIsValidPhoneNumber:(NSString *)string 
                  forCountryCode:(nullable NSString *)nillableCode {
    NSString *countryCode = [self countryCodeOrCurrentLocaleCountryFromString:nillableCode];
    
    if ([countryCode isEqualToString:@"US"]) {
        return [SPCardValidator sanitizedNumericStringForString:string].length == 10;
    } else {
        return YES;
    }
}

+ (NSString *)formattedSanitizedPhoneNumberForString:(NSString *)string {
    return [self formattedSanitizedPhoneNumberForString:string
                                         forCountryCode:nil];
}

+ (NSString *)formattedSanitizedPhoneNumberForString:(NSString *)string 
                                      forCountryCode:(nullable NSString *)nillableCode {
    NSString *countryCode = [self countryCodeOrCurrentLocaleCountryFromString:nillableCode];
    NSString *sanitized = [SPCardValidator sanitizedNumericStringForString:string];
    return [self formattedPhoneNumberForString:sanitized
                                forCountryCode:countryCode];
}

+ (NSString *)formattedRedactedPhoneNumberForString:(NSString *)string {
    return [self formattedRedactedPhoneNumberForString:string
                                        forCountryCode:nil];
}

+ (NSString *)formattedRedactedPhoneNumberForString:(NSString *)string
                                     forCountryCode:(nullable NSString *)nillableCode {
    NSString *countryCode = [self countryCodeOrCurrentLocaleCountryFromString:nillableCode];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSMutableString *prefix = [NSMutableString stringWithCapacity:string.length];
    [scanner scanUpToString:@"*" intoString:&prefix];
    NSString *number = [string stringByReplacingOccurrencesOfString:prefix withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"*" withString:@"•"];
    number = [self formattedPhoneNumberForString:number
                                  forCountryCode:countryCode];
    return [NSString stringWithFormat:@"%@ %@", prefix, number];
}

+ (NSString *)formattedPhoneNumberForString:(NSString *)string 
                             forCountryCode:(NSString *)countryCode {
    
    if (![countryCode isEqualToString:@"US"]) {
        return string;
    }
    if (string.length >= 6) {
        return [NSString stringWithFormat:@"(%@) %@-%@",
                [string sp_safeSubstringToIndex:3],
                [[string sp_safeSubstringToIndex:6] sp_safeSubstringFromIndex:3],
                [[string sp_safeSubstringToIndex:10] sp_safeSubstringFromIndex:6]
                ];
    } else if (string.length >= 3) {
        return [NSString stringWithFormat:@"(%@) %@",
                [string sp_safeSubstringToIndex:3],
                [string sp_safeSubstringFromIndex:3]
                ];
    }
    return string;
}

@end
