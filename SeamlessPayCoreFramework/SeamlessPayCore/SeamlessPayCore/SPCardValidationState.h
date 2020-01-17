//
//  SPCardValidationState.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

#import <Foundation/Foundation.h>

/**
 These fields indicate whether a card field represents a valid value, invalid 
 value, or incomplete value.
 */
typedef NS_ENUM(NSInteger, SPCardValidationState) {

    /**
     The field's contents are valid. For example, a valid, 16-digit card number.
     Note that valid values may not be complete. For example: a US Zip code can
     be 5 or 9 digits. A 5-digit code is Valid, but more text could be entered 
     to transition to incomplete again. American Express CVC codes can be 3 or 
     4 digits and both will be treated as Valid.
     */
    SPCardValidationStateValid,

    /**
     The field's contents are invalid. For example, an expiration date 
     of "13/42".
     */
    SPCardValidationStateInvalid,

    /**
     The field's contents are not currently valid, but could be by typing 
     additional characters. For example, a CVC of "1".
     */
    SPCardValidationStateIncomplete
};
