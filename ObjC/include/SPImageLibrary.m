/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPImageLibrary.h"

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

// MARK: - Private Methods

+ (NSString *)pathForImageWithName:(NSString *)imageName {
  NSString *path = nil;
#if SWIFT_PACKAGE
  path = [SWIFTPM_MODULE_BUNDLE pathForResource:imageName ofType:@"png"];
#else
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *resourceBundleURL = [bundle pathForResource:@"SeamlessPay" ofType:@"bundle"];
  NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundleURL];
  NSURL *imageURL = [resourceBundle URLForResource:imageName withExtension:@"png"];
  path = [imageURL path];
#endif
  return path;
}

+ (UIImage *)safeImageNamed:(NSString *)imageName
        templateIfAvailable:(BOOL)templateIfAvailable {

  NSString *path = [self pathForImageWithName:imageName];

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

+ (UIImage *)renewed_brandImageForCardBrand:(SPCardBrand)brand {
  NSString *imageName;
  switch (brand) {
    case SPCardBrandAmex:
      imageName = @"logo_amex_light";
      break;
    case SPCardBrandDiscover:
      imageName = @"logo_discover_light";
      break;
    case SPCardBrandMasterCard:
      imageName = @"logo_mastercard_light";
      break;
    case SPCardBrandVisa:
      imageName = @"logo_visa_light";
      break;
    default:
      imageName = @"sp_card_unknown";
      break;
  }
  UIImage *image = [self safeImageNamed:imageName templateIfAvailable:NO];
  return image;
}

+ (UIImage *)renewed_cvcImageTemplateForCardBrand:(SPCardBrand)brand {
  NSString *imageName = brand == SPCardBrandAmex ? @"amex_cvc_icon" : @"cvc_icon";
  UIImage *image = [self safeImageNamed:imageName];
  return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)renewed_errorImage {
  return [self safeImageNamed:@"error_sign"];
}

@end
