/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

/**
 The various bank brands available for FPX payments.
 */
typedef NS_ENUM(NSInteger, SPFPXBankBrand) {

  /**
   Maybank2U
   */
  SPFPXBankBrandMaybank2U,

  /**
   CIMB Clicks
   */
  SPFPXBankBrandCIMB,

  /**
   Public Bank
   */
  SPFPXBankBrandPublicBank,

  /**
   RHB Bank
   */
  SPFPXBankBrandRHB,

  /**
   Hong Leong Bank
   */
  SPFPXBankBrandHongLeongBank,

  /**
   AmBank
   */
  SPFPXBankBrandAmbank,

  /**
   Affin Bank
   */
  SPFPXBankBrandAffinBank,

  /**
   Alliance Bank
   */
  SPFPXBankBrandAllianceBank,

  /**
   Bank Islam
   */
  SPFPXBankBrandBankIslam,

  /**
   Bank Muamalat
   */
  SPFPXBankBrandBankMuamalat,

  /**
   Bank Rakyat
   */
  SPFPXBankBrandBankRakyat,

  /**
   BSN
   */
  SPFPXBankBrandBSN,

  /**
   HSBC BANK
   */
  SPFPXBankBrandHSBC,

  /**
   KFH
   */
  SPFPXBankBrandKFH,

  /**
   Maybank2E
   */
  SPFPXBankBrandMaybank2E,

  /**
   OCBC Bank
   */
  SPFPXBankBrandOcbc,

  /**
   Standard Chartered
   */
  SPFPXBankBrandStandardChartered,

  /**
   UOB Bank
   */
  SPFPXBankBrandUOB,

  /**
   An unknown bank
   */
  SPFPXBankBrandUnknown,
};

/**
 Returns a string representation for the provided bank brand;
 i.e. `[NSString stringFromBrand:SPCardBrandUob] ==  @"UOB Bank"`.

 @param brand The brand you want to convert to a string

 @return A string representing the brand, suitable for displaying to a user.
 */
NSString *SPStringFromFPXBankBrand(SPFPXBankBrand brand);

/**
 Returns a bank brand provided a string representation identifying a bank brand;
 i.e. `SPFPXBankBrandFromIdentifier(@"uob") == SPCardBrandUob`.

 @param identifier The identifier for the brand

 @return The SPFPXBankBrand enum value
 */
SPFPXBankBrand SPFPXBankBrandFromIdentifier(NSString *identifier);

NSString *SPIdentifierFromFPXBankBrand(SPFPXBankBrand brand);

/**
 Returns the code identifying the provided bank brand in the FPX status API;
 i.e. `SPIdentifierFromFPXBankBrand(SPCardBrandUob) ==  @"UOB0226"`.

 @param brand The brand you want to convert to an FPX bank code
 @param isBusiness Requests the code for the business version of this bank
 brand, which may be different from the code used for individual accounts

 @return A string representing the brand, suitable for checking against the FPX
 status API.
 */
NSString *SPBankCodeFromFPXBankBrand(SPFPXBankBrand brand, BOOL isBusiness);
