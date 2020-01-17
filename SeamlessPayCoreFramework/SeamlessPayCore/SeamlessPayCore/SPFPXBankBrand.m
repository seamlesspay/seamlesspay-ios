//
//  SPFPXBankBrand.m
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import "SPFPXBankBrand.h"

NSString * SPStringFromFPXBankBrand(SPFPXBankBrand brand) {
    switch (brand) {
        case SPFPXBankBrandAffinBank:
            return @"Affin Bank";
        case SPFPXBankBrandAllianceBank:
            return @"Alliance Bank";
        case SPFPXBankBrandAmbank:
            return @"AmBank";
        case SPFPXBankBrandBankIslam:
            return @"Bank Islam";
        case SPFPXBankBrandBankMuamalat:
            return @"Bank Muamalat";
        case SPFPXBankBrandBankRakyat:
            return @"Bank Rakyat";
        case SPFPXBankBrandBSN:
            return @"BSN";
        case SPFPXBankBrandCIMB:
            return @"CIMB Clicks";
        case SPFPXBankBrandHongLeongBank:
            return @"Hong Leong Bank";
        case SPFPXBankBrandHSBC:
            return @"HSBC BANK";
        case SPFPXBankBrandKFH:
            return @"KFH";
        case SPFPXBankBrandMaybank2E:
            return @"Maybank2E";
        case SPFPXBankBrandMaybank2U:
            return @"Maybank2U";
        case SPFPXBankBrandOcbc:
            return @"OCBC Bank";
        case SPFPXBankBrandPublicBank:
            return @"Public Bank";
        case SPFPXBankBrandRHB:
            return @"RHB Bank";
        case SPFPXBankBrandStandardChartered:
            return @"Standard Chartered";
        case SPFPXBankBrandUOB:
            return @"UOB Bank";
        case SPFPXBankBrandUnknown:
            return @"Unknown";
    }
}

SPFPXBankBrand SPFPXBankBrandFromIdentifier(NSString *identifier) {
    NSString *brand = [identifier lowercaseString];
    if ([brand isEqualToString:@"affin_bank"]) {
        return SPFPXBankBrandAffinBank;
    }
    if ([brand isEqualToString:@"alliance_bank"]) {
        return SPFPXBankBrandAllianceBank;
    }
    if ([brand isEqualToString:@"ambank"]) {
        return SPFPXBankBrandAmbank;
    }
    if ([brand isEqualToString:@"bank_islam"]) {
        return SPFPXBankBrandBankIslam;
    }
    if ([brand isEqualToString:@"bank_muamalat"]) {
        return SPFPXBankBrandBankMuamalat;
    }
    if ([brand isEqualToString:@"bank_rakyat"]) {
        return SPFPXBankBrandBankRakyat;
    }
    if ([brand isEqualToString:@"bsn"]) {
        return SPFPXBankBrandBSN;
    }
    if ([brand isEqualToString:@"cimb"]) {
        return SPFPXBankBrandCIMB;
    }
    if ([brand isEqualToString:@"hong_leong_bank"]) {
        return SPFPXBankBrandHongLeongBank;
    }
    if ([brand isEqualToString:@"hsbc"]) {
        return SPFPXBankBrandHSBC;
    }
    if ([brand isEqualToString:@"kfh"]) {
        return SPFPXBankBrandKFH;
    }
    if ([brand isEqualToString:@"maybank2e"]) {
        return SPFPXBankBrandMaybank2E;
    }
    if ([brand isEqualToString:@"maybank2u"]) {
        return SPFPXBankBrandMaybank2U;
    }
    if ([brand isEqualToString:@"ocbc"]) {
        return SPFPXBankBrandOcbc;
    }
    if ([brand isEqualToString:@"public_bank"]) {
        return SPFPXBankBrandPublicBank;
    }
    if ([brand isEqualToString:@"rhb"]) {
        return SPFPXBankBrandRHB;
    }
    if ([brand isEqualToString:@"standard_chartered"]) {
        return SPFPXBankBrandStandardChartered;
    }
    if ([brand isEqualToString:@"uob"]) {
        return SPFPXBankBrandUOB;
    }
    return SPFPXBankBrandUnknown;
}

NSString * SPIdentifierFromFPXBankBrand(SPFPXBankBrand brand) {
    switch (brand) {
        case SPFPXBankBrandAffinBank:
            return @"affin_bank";
        case SPFPXBankBrandAllianceBank:
            return @"alliance_bank";
        case SPFPXBankBrandAmbank:
            return @"ambank";
        case SPFPXBankBrandBankIslam:
            return @"bank_islam";
        case SPFPXBankBrandBankMuamalat:
            return @"bank_muamalat";
        case SPFPXBankBrandBankRakyat:
            return @"bank_rakyat";
        case SPFPXBankBrandBSN:
            return @"bsn";
        case SPFPXBankBrandCIMB:
            return @"cimb";
        case SPFPXBankBrandHongLeongBank:
            return @"hong_leong_bank";
        case SPFPXBankBrandHSBC:
            return @"hsbc";
        case SPFPXBankBrandKFH:
            return @"kfh";
        case SPFPXBankBrandMaybank2E:
            return @"maybank2e";
        case SPFPXBankBrandMaybank2U:
            return @"maybank2u";
        case SPFPXBankBrandOcbc:
            return @"ocbc";
        case SPFPXBankBrandPublicBank:
            return @"public_bank";
        case SPFPXBankBrandRHB:
            return @"rhb";
        case SPFPXBankBrandStandardChartered:
            return @"standard_chartered";
        case SPFPXBankBrandUOB:
            return @"uob";
        case SPFPXBankBrandUnknown:
            return @"unknown";
    }
}

NSString * SPBankCodeFromFPXBankBrand(SPFPXBankBrand brand, BOOL isBusiness) {
    switch (brand) {
        case SPFPXBankBrandAffinBank:
            if (isBusiness)
                return @"ABB0232";
            else
                return @"ABB0233";
        case SPFPXBankBrandAllianceBank:
            if (isBusiness)
                return @"ABMB0213";
            else
                return @"ABMB0212";
        case SPFPXBankBrandAmbank:
            if (isBusiness)
                return @"AMBB0208";
            else
                return @"AMBB0209";
        case SPFPXBankBrandBankIslam:
            if (isBusiness)
                return nil;
            else
                return @"BIMB0340";
        case SPFPXBankBrandBankMuamalat:
            if (isBusiness)
                return @"BMMB0342";
            else
                return @"BMMB0341";
        case SPFPXBankBrandBankRakyat:
            if (isBusiness)
                return @"BKRM0602";
            else
                return @"BKRM0602";
        case SPFPXBankBrandBSN:
            if (isBusiness)
                return nil;
            else
                return @"BSN0601";
        case SPFPXBankBrandCIMB:
            if (isBusiness)
                return @"BCBB0235";
            else
                return @"BCBB0235";
        case SPFPXBankBrandHongLeongBank:
            if (isBusiness)
                return @"HLB0224";
            else
                return @"HLB0224";
        case SPFPXBankBrandHSBC:
            if (isBusiness)
                return @"HSBC0223";
            else
                return @"HSBC0223";
        case SPFPXBankBrandKFH:
            if (isBusiness)
                return @"KFH0346";
            else
                return @"KFH0346";
        case SPFPXBankBrandMaybank2E:
            if (isBusiness)
                return @"MBB0228";
            else
                return @"MBB0228";
        case SPFPXBankBrandMaybank2U:
            if (isBusiness)
                return nil;
            else
                return @"MB2U0227";
        case SPFPXBankBrandOcbc:
            if (isBusiness)
                return @"OCBC0229";
            else
                return @"OCBC0229";
        case SPFPXBankBrandPublicBank:
            if (isBusiness)
                return @"PBB0233";
            else
                return @"PBB0233";
        case SPFPXBankBrandRHB:
            if (isBusiness)
                return @"RHB0218";
            else
                return @"RHB0218";
        case SPFPXBankBrandStandardChartered:
            if (isBusiness)
                return @"SCB0215";
            else
                return @"SCB0216";
        case SPFPXBankBrandUOB:
            if (isBusiness)
                return @"UOB0227";
            else
                return @"UOB0226";
        case SPFPXBankBrandUnknown:
            return @"unknown";
    }
}
