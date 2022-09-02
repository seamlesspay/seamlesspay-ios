//
//  SPApplePay.h
//  SeamlessPayCore
//
//  Created by SB on 12.08.2021.
//

#import <PassKit/PassKit.h>


@interface SPApplePay : NSObject

/**
 *  Whether or not this device is capable of using Apple Pay. This checks both whether the user is running an iPhone 6/6+ or later, iPad Air 2 or later, or iPad
 *mini 3 or later, as well as whether or not they have stored any cards in Apple Pay on their device.
 *
 *  @param paymentRequest The return value of this method depends on the supportedNetworks property of this payment request, which by default should be
 *@[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa].
 *
 *  @return whether or not the user is currently able to pay with Apple Pay.
 */
+ (BOOL)canSubmitPaymentRequest:(nullable PKPaymentRequest *)paymentRequest;

/**
 *  A convenience method to return a PKPaymentRequest with sane default values. You will still need to configure the paymentSummaryItems property to indicate
 *what the user is purchasing, as well as the optional requiredShippingAddressFields, requiredBillingAddressFields, and shippingMethods properties to indicate
 *what contact information your application requires.
 *
 *  @param merchantIdentifier Your Apple Merchant ID, as obtained at https://developer.apple.com/account/ios/identifiers/merchant/merchantCreate.action
 *
 *  @return a PKPaymentRequest with proper default values. Returns nil if running on < iOS8.
 */
+ (nullable PKPaymentRequest *)paymentRequestWithMerchantIdentifier:(nonnull NSString *)merchantIdentifier
                                                paymentSummaryItems:(nonnull NSArray<PKPaymentSummaryItem*> *)paymentSummaryItems
                                              paymentsUsingNetworks:(NSArray<PKPaymentNetwork> *_Nullable)supportedNetworks;

+ (nonnull PKPaymentButton *)paymentButtonWithStyle:(PKPaymentButtonStyle)buttonStyle
                              paymentsUsingNetworks:(NSArray<PKPaymentNetwork> *_Nullable)supportedNetworks;
@end
