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
    // Do any additional setup after loading the view.
    
    SPPaymentCardTextField *cardTextField = [[SPPaymentCardTextField alloc] init];
    cardTextField.postalCodeEntryEnabled = TRUE;
    cardTextField.countryCode = @"US";
    self.cardTextField = cardTextField;
    
    UITextField *amountTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 0, 150, 22)];
    amountTextField.text = @"$0.00";
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
    
    UILabel *infoLbel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    infoLbel.userInteractionEnabled = TRUE;
    infoLbel.textColor = [UIColor darkGrayColor];
    infoLbel.text = @"Amount:";
    
    [infoLbel addSubview:amountTextField];
    
    UIStackView *stackView = [[UIStackView alloc]
                              initWithArrangedSubviews:@[ infoLbel, cardTextField, button ]];
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
         multiplier:20],
    ]];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
}

- (void)displayAlertWithTitle:(NSString *)title
                      message:(NSString *)message 
                      {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:title
                         message:message
                  preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
  });
}

- (void)pay {

  [self.activityIndicator startAnimating];

  [[SPAPIClient getSharedInstance] createPaymentMethodWithType:@"CREDIT_CARD"
      account:self.cardTextField.cardNumber
      expDate:self.cardTextField.formattedExpirationDate
      cvv:self.cardTextField.cvc
      accountType:nil
      routing:nil
      pin:nil
      address:nil
      address2:nil
      city:nil
      country:nil
      state:nil
      zip:self.cardTextField.postalCode
      company:nil
      email:nil
      phone:nil
      name:nil
      nickname:nil
      verification : TRUE
      success:^(SPPaymentMethod *paymentMethod) {
        [[SPAPIClient getSharedInstance]
            createChargeWithToken:paymentMethod.token
            cvv:self.cardTextField.cvc
            capture: TRUE
            currency:nil
            amount:[[self.amountTextField.text substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""]
            taxAmount:nil
            taxExempt: FALSE
            tip:nil
            surchargeFeeAmount:nil
            scheduleIndicator:nil
            description:nil
            order:nil
            orderId:nil
            poNumber:nil
            metadata:nil
            descriptor:nil
            txnEnv:nil
            achType:nil
            credentialIndicator:nil
            transactionInitiation:nil
            idempotencyKey:nil
            needSendReceipt:FALSE
            success:^(SPCharge *charge) {
              [self.activityIndicator stopAnimating];
              NSString *success = [NSString
                  stringWithFormat:@"Amount: $%@\nStatus: %@\nStatus message: "
                                   @"%@\ntxnID #: %@",
                                   charge.amount, charge.status,
                                   charge.statusDescription, charge.chargeId];

              [self displayAlertWithTitle:@"Success"
                                  message:success];
            }
            failure:^(SPError *error) {
              [self.activityIndicator stopAnimating];
              NSString *err = [error localizedDescription];
              [self displayAlertWithTitle:@"Error creating Charge"
                                  message:err];
            }];
      }
      failure:^(SPError *error) {
        [self.activityIndicator stopAnimating];
        NSString *err = [error localizedDescription];
        [self displayAlertWithTitle:@"Error creating Charge"
                            message:err];
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
        
        myNumber = result;
        NSNumber *formatedValue;
        formatedValue = [[NSNumber alloc] initWithDouble:[myNumber doubleValue] / 100.0f];
        NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
        _currencyFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        textField.text = [_currencyFormatter stringFromNumber:formatedValue];

        return FALSE;
    } else {
        return FALSE;
    }
    return TRUE;
}

@end
