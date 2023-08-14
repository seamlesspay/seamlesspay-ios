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
@property(nonatomic, strong) UIImage *logoImage;
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
@property(nonatomic) SPPaymentType paymentType;

@property(nonatomic, strong) SPAddress *billingAddress;
@property(nonatomic, strong) SPCustomer *customer;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *paymentMetadata;


@property(nonatomic, assign) id<SPPaymentViewControllerDelegate> delegate;

@end
