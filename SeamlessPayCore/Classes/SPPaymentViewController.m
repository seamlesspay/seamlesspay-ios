/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import "SPPaymentViewController.h"


@interface SPPaymentViewController () <UITextFieldDelegate>


@end

@implementation SPPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SPPaymentCardTextField *cardTextField = [[SPPaymentCardTextField alloc] init];
    cardTextField.postalCodeEntryEnabled = TRUE;
    cardTextField.countryCode = @"US";
    self.cardTextField = cardTextField;
    
    UITextField *amountTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 0, 150, 22)];
    amountTextField.text = [self formatedValue:@([self.paymentAmount floatValue]*100) ?: @(0)];
    amountTextField.keyboardType = UIKeyboardTypeNumberPad;
    amountTextField.delegate = self;
    self.amountTextField = amountTextField;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor systemBlueColor];
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    [button setTitle:@"Pay" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(pay)
     forControlEvents:UIControlEventTouchUpInside];
    self.payButton = button;
    
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    amountLabel.userInteractionEnabled = _isEditAmount;
    amountLabel.textColor = [UIColor darkGrayColor];
    amountLabel.text = @"Amount:";
    [amountLabel addSubview:amountTextField];
    self.amountLabel = amountLabel;
    
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.text = [_paymentDescription copy];
    descriptionLabel.font = [UIFont systemFontOfSize:13];
    descriptionLabel.textColor = [UIColor grayColor];
    descriptionLabel.numberOfLines = 2;
    [descriptionLabel sizeToFit];
    self.descriptionLabel = descriptionLabel;
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:self.logoImage];
    logoImageView.contentMode = UIViewContentModeCenter;

    UIStackView *stackView = [[UIStackView alloc]
                              initWithArrangedSubviews:@[logoImageView, amountLabel, descriptionLabel, cardTextField, button ]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.translatesAutoresizingMaskIntoConstraints = FALSE;
    stackView.spacing = 20;
    [self.view addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leftAnchor
         constraintEqualToSystemSpacingAfterAnchor:self.view.leftAnchor
         multiplier:2],
        [self.view.rightAnchor
         constraintEqualToSystemSpacingAfterAnchor:stackView.rightAnchor
         multiplier:2],
        [stackView.topAnchor
         constraintEqualToSystemSpacingBelowAnchor:self.view.topAnchor
         multiplier:2],
    ]];
    
    self.activityIndicator = [[SPLoadingView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];;
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.lineColor = [UIColor systemBlueColor];
    [self.view addSubview:self.activityIndicator];
}

- (void)pay {
    
   self.paymentAmount = [[self.amountTextField.text substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""];

  [self.activityIndicator startAnimation];

  [[SPAPIClient getSharedInstance] createPaymentMethodWithType:@"CREDIT_CARD"
      account:self.cardTextField.cardNumber
      expDate:self.cardTextField.formattedExpirationDate
      cvv:self.cardTextField.cvc
      accountType:nil
      routing:nil
      pin:nil
      address:self.billingAddress
      address2:self.billingAddress2
      city:self.billingCity
      country:self.billingCountry
      state:self.billingState
      zip:self.cardTextField.postalCode?:self.billingZip
      company:self.company
      email:self.email
      phone:self.phoneNumber
      name:self.name
      nickname:self.nickname
      verification : self.isVerification
      success:^(SPPaymentMethod *paymentMethod) {
      
        if ([self.delegate respondsToSelector:@selector(paymentViewController:paymentMethodSuccess:)]) {
           [self.delegate paymentViewController:self paymentMethodSuccess:paymentMethod];
        }
      
        [[SPAPIClient getSharedInstance]
            createChargeWithToken:paymentMethod.token
            cvv:self.cardTextField.cvc
            capture: TRUE
            currency:nil
            amount:self.paymentAmount
            taxAmount:nil
            taxExempt: FALSE
            tip:nil
            surchargeFeeAmount:nil
            scheduleIndicator:nil
            description:self.paymentDescription
            order:nil
            orderId:self.orderId
            poNumber:nil
            metadata:self.paymentMetadata
            descriptor:nil
            txnEnv:nil
            achType:nil
            credentialIndicator:nil
            transactionInitiation:nil
            idempotencyKey: self.idempotencyKey
            needSendReceipt:self.isNeedSendReceipt
            success:^(SPCharge *charge) {
              [self.activityIndicator stopAnimation];
              if ([self.delegate respondsToSelector:@selector(paymentViewController:chargeSuccess:)]) {
                 [self.delegate paymentViewController:self chargeSuccess:charge];
              }
            }
            failure:^(SPError *error) {
              [self.activityIndicator stopAnimation];
              if ([self.delegate respondsToSelector:@selector(paymentViewController:chargeError:)]) {
                 [self.delegate paymentViewController:self chargeError:error];
              }
            }];
      }
      failure:^(SPError *error) {
      [self.activityIndicator stopAnimation];
      
      if ([self.delegate respondsToSelector:@selector(paymentViewController:paymentMethodError:)]) {
          [self.delegate paymentViewController:self paymentMethodError:error];
      }
  }];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSInteger centValue = [cleanCentString intValue];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSNumber *myNumber = [f numberFromString:cleanCentString];
    NSNumber *result;
    
    if ([textField.text length] < 16) {
        if (string.length > 0) {
            centValue = centValue * 10 + [string intValue];
            double intermediate = [myNumber doubleValue] * 10 +  [[f numberFromString:string] doubleValue];
            result = [[NSNumber alloc] initWithDouble:intermediate];
        } else {
            centValue = centValue / 10;
            double intermediate = [myNumber doubleValue]/10;
            result = [[NSNumber alloc] initWithDouble:intermediate];
        }
        textField.text = [self formatedValue:result];

        return FALSE;
    } else {
        return FALSE;
    }
    return TRUE;
}

- (NSString *)formatedValue:(NSNumber*)myNumber {
    NSNumber *formatedValue;
    formatedValue = [[NSNumber alloc] initWithDouble:[myNumber doubleValue] / 100.0f];
    NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
    _currencyFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return  [_currencyFormatter stringFromNumber:formatedValue];
}

@end
