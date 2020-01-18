//
//  SPFormEncoder.m
//

#import "SPFormEncoder.h"

#import "SPFormEncodable.h"

FOUNDATION_EXPORT NSString * SPPercentEscapedStringFromString(NSString *string);
FOUNDATION_EXPORT NSString * SPQueryStringFromParameters(NSDictionary *parameters);

@implementation SPFormEncoder

+ (NSString *)stringByReplacingSnakeCaseWithCamelCase:(NSString *)input {
    NSArray *parts = [input componentsSeparatedByString:@"_"];
    NSMutableString *camelCaseParam = [NSMutableString string];
    [parts enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, __unused BOOL *stop) {
        [camelCaseParam appendString:(idx == 0 ? part : [part capitalizedString])];
    }];
    
    return [camelCaseParam copy];
}

+ (NSDictionary *)dictionaryForObject:(nonnull NSObject<SPFormEncodable> *)object {
    NSDictionary *keyPairs = [self keyPairDictionaryForObject:object];
    NSString *rootObjectName = [object.class rootObjectName];
    NSDictionary *dict = rootObjectName != nil ? @{ rootObjectName: keyPairs } : keyPairs;
    return dict;
}

+ (NSDictionary *)keyPairDictionaryForObject:(nonnull NSObject<SPFormEncodable> *)object {
    NSMutableDictionary *keyPairs = [NSMutableDictionary dictionary];
    [[object.class propertyNamesToFormFieldNamesMapping] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull propertyName, NSString *  _Nonnull formFieldName, __unused BOOL * _Nonnull stop) {
        id value = [self formEncodableValueForObject:[object valueForKey:propertyName]];
        if (value) {
            keyPairs[formFieldName] = value;
        }
    }];

    return [keyPairs copy];
}

+ (id)formEncodableValueForObject:(NSObject *)object {
    if ([object conformsToProtocol:@protocol(SPFormEncodable)]) {
        return [self keyPairDictionaryForObject:(NSObject<SPFormEncodable>*)object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)object;
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:dict.count];

        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, __unused BOOL * _Nonnull stop) {
            result[[self formEncodableValueForObject:key]] = [self formEncodableValueForObject:value];
        }];

        return result;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)object;
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];

        for (NSObject *element in array) {
            [result addObject:[self formEncodableValueForObject:element]];
        }
        return result;
    } else if ([object isKindOfClass:[NSSet class]]) {
        NSSet *set = (NSSet *)object;
        NSMutableSet *result = [NSMutableSet setWithCapacity:set.count];

        for (NSObject *element in set) {
            [result addObject:[self formEncodableValueForObject:element]];
        }
        return result;
    } else {
        return object;
    }
}

+ (NSString *)stringByURLEncoding:(NSString *)string {
    return SPPercentEscapedStringFromString(string);
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
    return SPQueryStringFromParameters(parameters);
}

@end



NSString * SPPercentEscapedStringFromString(NSString *string) {
    static NSString * const kSPCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kSPCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kSPCharactersGeneralDelimitersToEncode stringByAppendingString:kSPCharactersSubDelimitersToEncode]];
    

    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

#pragma mark -

@interface SPQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)stringValue;
@end

@implementation SPQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _field = field;
    _value = value;
    
    return self;
}

- (NSString *)stringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return [self.field description] ? : @"";
    } else {
        return [NSString stringWithFormat:@"%@=%@", [self.field description], [self.value description]];
    }
}

@end

#pragma mark -

FOUNDATION_EXPORT NSArray * SPQueryStringPairsFromKeyAndValue(NSString *key, id value);
FOUNDATION_EXPORT id SPPercentEscapedObject(id object);

NSString * SPQueryStringFromParameters(NSDictionary *parameters) {
    
    if (!parameters) {
        return @"";
    }
    
    // Escape any reserved characters. due to the implementation of `SPQueryStringPairsFromKeyAndValue`, it's much easier to do this now, as when that function is called recursively on a dictionary, `key` will (correctly) contain characters like `[]`.
    NSDictionary *escaped = SPPercentEscapedObject(parameters);
    
    NSString *descriptionSelector = NSStringFromSelector(@selector(description));
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:descriptionSelector ascending:YES selector:@selector(compare:)];
    
    // For each dictionary key-value pair, form-encode the pair (potentially recursively). Thus {foo: {bar: "baz"}} becomes the tuple, ("foo[bar]", "baz"). Each one of these tuples will become a key/value pair in the final query string (e.g. POST /v1/charges?foo[bar]=baz).
    NSMutableArray *mutablePairs = [NSMutableArray array];    
    for (id key in [escaped.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
        id value = escaped[key];
        NSArray *pairs = SPQueryStringPairsFromKeyAndValue(key, value);
        [mutablePairs addObjectsFromArray:pairs];
    }
    
    NSMutableArray *mutablePathComponents = [NSMutableArray array];
    for (SPQueryStringPair *pair in mutablePairs) {
        [mutablePathComponents addObject:[pair stringValue]];
    }
    
    return [mutablePathComponents componentsJoinedByString:@"&"];
}

// This function recursively converts an object into a version that is safe to convert into
// a form-encoded path string by escaping any reserved characters in it or its children.
id SPPercentEscapedObject(id object) {
    if (!object || object == [NSNull null]) {
        return @"";
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *escapedArray = [NSMutableArray array];
        for (id subObject in object) {
            [escapedArray addObject:SPPercentEscapedObject(subObject)];
        }
        return escapedArray;
    } else if ([object isKindOfClass:[NSSet class]]) {
        NSMutableSet *escapedSet = [NSMutableSet set];
        for (id subObject in object) {
            [escapedSet addObject:SPPercentEscapedObject(subObject)];
        }
        return escapedSet;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *escapedDictionary = [NSMutableDictionary dictionary];
        for (id key in object) {
            id escapedKey = SPPercentEscapedStringFromString([key description]);
            id subObject = object[key];
            escapedDictionary[escapedKey] = SPPercentEscapedObject(subObject);
        }
        return escapedDictionary;
    } else if ([object isKindOfClass:[NSNumber class]]
               && (CFBooleanGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(object)))) {
        // Unbox NSNumbers containing booleans
        // https://stackoverflow.com/a/30223989/1196205
        return [object boolValue] ? @"true" : @"false";
    } else {
        return SPPercentEscapedStringFromString([object description]);
    }
}

NSArray * SPQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    NSString *descriptionSelector = NSStringFromSelector(@selector(description));
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:descriptionSelector ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when serializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            // Call ourselves recursively, building up a larger param string
            NSString *combinedKey = [NSString stringWithFormat:@"%@[%@]", key, nestedKey];
            [mutableQueryStringComponents addObjectsFromArray:SPQueryStringPairsFromKeyAndValue(combinedKey, nestedValue)];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull nestedValue, NSUInteger idx, __unused BOOL * _Nonnull stop) {
            [mutableQueryStringComponents addObjectsFromArray:SPQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[%lu]", key, (unsigned long)idx], nestedValue)];
        }];
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:SPQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[SPQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}
