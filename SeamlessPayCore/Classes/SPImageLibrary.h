//
//  SPImages.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPFPXBankBrand.h"
#import "SPCardBrand.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class lets you access card icons 
 */
@interface SPImageLibrary : NSObject

/**
 An icon representing Apple Pay.
 */
+ (UIImage *)applePayCardImage;

/**
 An icon representing American Express.
 */
+ (UIImage *)amexCardImage;

/**
 An icon representing Diners Club.
 */
+ (UIImage *)dinersClubCardImage;

/**
 An icon representing Discover.
 */
+ (UIImage *)discoverCardImage;

/**
 An icon representing JCB.
 */
+ (UIImage *)jcbCardImage;

/**
 An icon representing Mastercard.
 */
+ (UIImage *)masterCardCardImage;

/**
 An icon representing UnionPay.
 */
+ (UIImage *)unionPayCardImage;

/**
 An icon representing Visa.
 */
+ (UIImage *)visaCardImage;

/**
 An icon to use when the type of the card is unknown.
 */
+ (UIImage *)unknownCardCardImage;

/**
 This returns the appropriate icon for the specified card brand.
 */
+ (UIImage *)brandImageForCardBrand:(SPCardBrand)brand;

/**
This returns the appropriate icon for the specified bank brand.
*/
+ (UIImage *)brandImageForFPXBankBrand:(SPFPXBankBrand)brand;

/**
 An icon representing FPX.
 */
+ (UIImage *)fpxLogo;

/**
 A large branding image for FPX.
 */
+ (UIImage *)largeFpxLogo;

/**
 This returns the appropriate icon for the specified card brand as a 
 single color template that can be tinted
 */
+ (UIImage *)templatedBrandImageForCardBrand:(SPCardBrand)brand;

/**
 This returns a small icon indicating the CVC location for the given card brand.
 */
+ (UIImage *)cvcImageForCardBrand:(SPCardBrand)brand;

/**
 This returns a small icon indicating a card number error for the given card brand.
 */
+ (UIImage *)errorImageForCardBrand:(SPCardBrand)brand;

@end

NS_ASSUME_NONNULL_END
