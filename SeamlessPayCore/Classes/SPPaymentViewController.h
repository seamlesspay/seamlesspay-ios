/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import "SPPaymentCardTextField.h"
#import "SPAPIClient.h"
#import "SPPaymentMethod.h"
#import "SPCharge.h"
#import "SPError.h"
#import "SPLoadingView.h"

@class SPPaymentViewController;
@protocol SPPaymentViewControllerDelegate <NSObject>
@required
- (void)paymentViewController:(SPPaymentViewController*)paymentViewController chargeSuccess:(SPCharge*)charge;
- (void)paymentViewController:(SPPaymentViewController*)paymentViewController paymentMethodError:(SPError*)error;
- (void)paymentViewController:(SPPaymentViewController*)paymentViewController chargeError:(SPError*)error;

@optional
- (void)paymentViewController:(SPPaymentViewController*)paymentViewController paymentMethodSuccess:(SPPaymentMethod*)paymentMethod;
@end


@interface SPPaymentViewController : UIViewController

@property(nonatomic, strong) SPLoadingView *activityIndicator;
@property(nonatomic, weak) SPPaymentCardTextField *cardTextField;
@property(nonatomic, weak) UITextField *amountTextField;
@property(nonatomic, weak) UIButton *payButton;
@property(nonatomic, weak) UILabel *amountLabel;
@property(nonatomic, weak) UILabel *descriptionLabel;

@property(nonatomic) BOOL isEditAmount;
@property(nonatomic) BOOL isVerification;
@property(nonatomic, strong) NSString *idempotencyKey;
@property(nonatomic, strong) NSString *orderId;
@property(nonatomic, strong) NSString *paymentDescription;
@property(nonatomic, strong) NSString *paymentAmount;

@property(nonatomic, strong) NSString *billingAddress;
@property(nonatomic, strong) NSString *billingAddress2;
@property(nonatomic, strong) NSString *billingCity;
@property(nonatomic, strong) NSString *billingState;
@property(nonatomic, strong) NSString *billingZip;
@property(nonatomic, strong) NSString *billingCountry;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *company;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSDictionary *paymentMetadata;
@property(nonatomic) BOOL isNeedSendReceipt;

@property(nonatomic, assign) id<SPPaymentViewControllerDelegate> delegate;

@end
