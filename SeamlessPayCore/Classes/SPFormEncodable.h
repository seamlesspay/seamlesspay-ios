//
//  SPFormEncodable.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol SPFormEncodable <NSObject>

+ (nullable NSString *)rootObjectName;

+ (NSDictionary *)propertyNamesToFormFieldNamesMapping;


@end

NS_ASSUME_NONNULL_END
