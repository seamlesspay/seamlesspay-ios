//
//  SPCustomer.h
//  SeamlessPayCore
//


#import <Foundation/Foundation.h>
#import "SPPaymentMethod.h"

@interface SPCustomer : NSObject
/**
 * Unique identifier for the object.
 */
@property(nonatomic, readonly, copy) NSString *custId;
/**
 * The customer's name.
 */
@property(nonatomic, readonly, copy) NSString *name;
/**
 * Customer email.
 */
@property(nonatomic, readonly, copy) NSString *email;
/**
 * The customer's first address
 */
@property(nonatomic, readonly, copy) NSString *address;
/**
 * The customer's second address.
 */
@property(nonatomic, readonly, copy) NSString *address2;
/**
 *  The customer's city.
 */
@property(nonatomic, readonly, copy) NSString *city;
/**
 *   The customer's state.
 */
@property(nonatomic, readonly, copy) NSString *state;
/**
 *  The customer's zip code.
 */
@property(nonatomic, readonly, copy) NSString *zip;
/**
 *  The customer's country.
 */
@property(nonatomic, readonly, copy) NSString *country;
/**
 *  The customer's company name.
 */
@property(nonatomic, readonly, copy) NSString *companyName;
/**
 *  Custom json object
 */
@property(nonatomic, readonly, copy) NSString *metadata;
/**
 *   The customer's phone number.
 */
@property(nonatomic, readonly, copy) NSString *phone;
/**
 *  The customer's payment methods.
 *   NSArray of objects (SPPaymentMethod)
 */
@property(nonatomic, readonly, copy) NSArray *paymentMethods;
/**
 *   The customer's website.
 */
@property(nonatomic, readonly, copy) NSString *website;



/**
 * Initializes instance of SPCustomer .
 */

+ (instancetype)customerWithResponseData:(NSData * )data;
- (instancetype)initWithResponseData:(NSData * )data;

- (NSDictionary*)dictionary;

@end
