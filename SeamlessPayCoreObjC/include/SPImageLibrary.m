/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPImageLibrary.h"
#import "SPImageLibrary+Extras.h"

// Dummy class for locating the framework bundle

@implementation SPImageLibrary

+ (UIImage *)applePayCardImage {
  return [self safeImageNamed:@"sp_card_applepay"];
}

+ (UIImage *)amexCardImage {
  return [self brandImageForCardBrand:SPCardBrandAmex];
}

+ (UIImage *)dinersClubCardImage {
  return [self brandImageForCardBrand:SPCardBrandDinersClub];
}

+ (UIImage *)discoverCardImage {
  return [self brandImageForCardBrand:SPCardBrandDiscover];
}

+ (UIImage *)jcbCardImage {
  return [self brandImageForCardBrand:SPCardBrandJCB];
}

+ (UIImage *)masterCardCardImage {
  return [self brandImageForCardBrand:SPCardBrandMasterCard];
}

+ (UIImage *)unionPayCardImage {
  return [self brandImageForCardBrand:SPCardBrandUnionPay];
}

+ (UIImage *)visaCardImage {
  return [self brandImageForCardBrand:SPCardBrandVisa];
}

+ (UIImage *)unknownCardCardImage {
  return [self brandImageForCardBrand:SPCardBrandUnknown];
}

+ (UIImage *)brandImageForCardBrand:(SPCardBrand)brand {
  return [self brandImageForCardBrand:brand template:NO];
}

+ (UIImage *)templatedBrandImageForCardBrand:(SPCardBrand)brand {
  return [self brandImageForCardBrand:brand template:YES];
}

+ (UIImage *)cvcImageForCardBrand:(SPCardBrand)brand {
  NSString *imageName =
  brand == SPCardBrandAmex ? @"sp_card_cvc_amex" : @"sp_card_cvc";
  return [self safeImageNamed:imageName];
}

+ (UIImage *)errorImageForCardBrand:(SPCardBrand)brand {
  NSString *imageName =
  brand == SPCardBrandAmex ? @"sp_card_error_amex" : @"sp_card_error";
  return [self safeImageNamed:imageName];
}

+ (UIImage *)safeImageNamed:(NSString *)imageName {
  return [self safeImageNamed:imageName templateIfAvailable:NO];
}

+ (UIImage *)brandImageForFPXBankBrand:(SPFPXBankBrand)brand {
  NSString *imageName = [NSString
                         stringWithFormat:@"sp_bank_fpx_%@", SPIdentifierFromFPXBankBrand(brand)];
  UIImage *image = [self safeImageNamed:imageName templateIfAvailable:NO];
  return image;
}

+ (UIImage *)largeFpxLogo {
  return [self safeImageNamed:@"sp_fpx_big_logo" templateIfAvailable:NO];
}

+ (UIImage *)fpxLogo {
  return [self safeImageNamed:@"sp_fpx_logo" templateIfAvailable:NO];
}

@end

@implementation SPImageLibrary (Extras)

+ (UIImage *)addIcon {
  return [self safeImageNamed:@"sp_icon_add" templateIfAvailable:YES];
}

+ (UIImage *)bankIcon {
  return [self safeImageNamed:@"sp_icon_bank" templateIfAvailable:YES];
}

+ (UIImage *)checkmarkIcon {
  return [self safeImageNamed:@"sp_icon_checkmark" templateIfAvailable:YES];
}

+ (UIImage *)largeCardFrontImage {
  return [self safeImageNamed:@"sp_card_form_front" templateIfAvailable:YES];
}

+ (UIImage *)largeCardBackImage {
  return [self safeImageNamed:@"sp_card_form_back" templateIfAvailable:YES];
}

+ (UIImage *)largeCardAmexCVCImage {
  return [self safeImageNamed:@"sp_card_form_amex_cvc" templateIfAvailable:YES];
}

+ (UIImage *)largeShippingImage {
  return [self safeImageNamed:@"sp_shipping_form" templateIfAvailable:YES];
}

+ (UIImage *)safeImageNamed:(NSString *)imageName
        templateIfAvailable:(BOOL)templateIfAvailable {

#if SWIFT_PACKAGE
  NSString *path = [SWIFTPM_MODULE_BUNDLE pathForResource:imageName ofType:@"png"];
#else
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSURL *imageURL = [mainBundle URLForResource:imageName
                                 withExtension:@"png"
                                  subdirectory:@"Frameworks/SeamlessPayCore.framework"
                                  localization:nil];

  NSString *path = [imageURL path];
#endif

  UIImage *image = [UIImage imageWithContentsOfFile:path];

  if (image == nil) {
    image = [UIImage imageNamed:imageName];
  }
  if (templateIfAvailable) {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  return image;
}

+ (UIImage *)brandImageForCardBrand:(SPCardBrand)brand
                           template:(BOOL)isTemplate {
  BOOL shouldUseTemplate = isTemplate;
  NSString *imageName;
  switch (brand) {
    case SPCardBrandAmex:
      imageName = shouldUseTemplate ? @"sp_card_amex_template" : @"sp_card_amex";
      break;
    case SPCardBrandDinersClub:
      imageName =
      shouldUseTemplate ? @"sp_card_diners_template" : @"sp_card_diners";
      break;
    case SPCardBrandDiscover:
      imageName =
      shouldUseTemplate ? @"sp_card_discover_template" : @"sp_card_discover";
      break;
    case SPCardBrandJCB:
      imageName = shouldUseTemplate ? @"sp_card_jcb_template" : @"sp_card_jcb";
      break;
    case SPCardBrandMasterCard:
      imageName = shouldUseTemplate ? @"sp_card_mastercard_template"
      : @"sp_card_mastercard";
      break;
    case SPCardBrandUnionPay:
      if ([[[NSLocale currentLocale] localeIdentifier].lowercaseString
           hasPrefix:@"zh"]) {
        imageName = shouldUseTemplate ? @"sp_card_unionpay_template_zh"
        : @"sp_card_unionpay_zh";
      } else {
        imageName = shouldUseTemplate ? @"sp_card_unionpay_template_en"
        : @"sp_card_unionpay_en";
      }
      break;
    case SPCardBrandUnknown:
      shouldUseTemplate = YES;
      imageName = @"sp_card_unknown";
      break;
    case SPCardBrandVisa:
      imageName = shouldUseTemplate ? @"sp_card_visa_template" : @"sp_card_visa";
      break;
  }
  UIImage *image = [self safeImageNamed:imageName
                    templateIfAvailable:shouldUseTemplate];
  return image;
}

+ (UIImage *)imageWithTintColor:(UIColor *)color forImage:(UIImage *)image {
  UIImage *newImage;
  UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
  [color set];
  UIImage *templateImage =
  [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [templateImage drawInRect:CGRectMake(0, 0, templateImage.size.width,
                                       templateImage.size.height)];
  newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
