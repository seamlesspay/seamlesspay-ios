//
//  SPApplePay.m
//  SeamlessPayCore
//
//  Created by SB on 12.08.2021.
//

#import "SPApplePay.h"
#import <Foundation/Foundation.h>

@implementation SPApplePay

+ (BOOL)canSubmitPaymentRequest:(PKPaymentRequest *)paymentRequest {
    if (paymentRequest == nil) {
        return NO;
    }
    return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentRequest.supportedNetworks];
}

+ (PKPaymentRequest *)paymentRequestWithMerchantIdentifier:(NSString *)merchantIdentifier
                                       paymentSummaryItems:(nonnull NSArray<PKPaymentSummaryItem*> *)paymentSummaryItems
                                     paymentsUsingNetworks:(NSArray<PKPaymentNetwork> *)supportedNetworks {
    if (![PKPaymentRequest class]) {
        return nil;
    }
    PKPaymentRequest *paymentRequest = [PKPaymentRequest new];
    [paymentRequest setMerchantIdentifier:merchantIdentifier];
    [paymentRequest setPaymentSummaryItems:paymentSummaryItems];
    [paymentRequest setSupportedNetworks:supportedNetworks?:@[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]];
    [paymentRequest setMerchantCapabilities:PKMerchantCapabilityDebit | PKMerchantCapabilityCredit | PKMerchantCapabilityEMV | PKMerchantCapability3DS];
    [paymentRequest setCountryCode:@"US"];
    [paymentRequest setCurrencyCode:@"USD"];
    paymentRequest.requiredBillingContactFields = [NSSet setWithArray:@[PKContactFieldPostalAddress, PKContactFieldName, PKContactFieldPhoneNumber, PKContactFieldEmailAddress]];
    paymentRequest.requiredShippingContactFields = [NSSet setWithArray:@[PKContactFieldPhoneNumber, PKContactFieldEmailAddress]];
    
    return paymentRequest;
}

+ (PKPaymentButton *)paymentButtonWithStyle:(PKPaymentButtonStyle)buttonStyle
                      paymentsUsingNetworks:(NSArray<PKPaymentNetwork> *)supportedNetworks {
    PKPaymentButtonType type;
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks?:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]]) {
        type = PKPaymentButtonTypeBuy;
    }
    else {
        type = PKPaymentButtonTypeSetUp;
    }

    PKPaymentButton *button = [[PKPaymentButton alloc] initWithPaymentButtonType:type paymentButtonStyle:PKPaymentButtonStyleWhiteOutline];
    button.tag = type;
    
    return button;
}

@end
