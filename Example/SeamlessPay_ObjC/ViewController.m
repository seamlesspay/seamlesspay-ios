/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@import SeamlessPayCore;

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, weak) SPPaymentCardTextField *cardTextField;
@property(nonatomic, weak) UITextField *amountTextField;
@property(nonatomic, weak) UIButton *payButton;

@end

@implementation ViewController

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
                  restartDemo:(BOOL)restartDemo {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        if (restartDemo) {
            [alert addAction:[UIAlertAction
                              actionWithTitle:@"Restart demo"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction *action) {
                [self.cardTextField clear];
                self.cardTextField.postalCodeEntryEnabled = TRUE;
                self.cardTextField.countryCode = @"US";
            }]];
        } else {
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)pay {
    
    [self.activityIndicator startAnimating];
    
    SPAddress * billingAddress = [[SPAddress alloc]
                                  initWithline1:nil
                                  line2:nil
                                  city:nil
                                  country:nil
                                  state:nil
                                  postalCode:self.cardTextField.postalCode];
    
    [[SPAPIClient getSharedInstance]
     tokenizeWithPaymentType:SPPaymentTypeCreditCard
     accountNumber:self.cardTextField.cardNumber
     expDate:self.cardTextField.formattedExpirationDate
     cvv:self.cardTextField.cvc
     accountType:nil
     routing:nil
     pin:nil
     billingAddress:billingAddress
     name:@"Michael Smith"
     success:^(SPPaymentMethod *paymentMethod) {
        
        [[SPAPIClient getSharedInstance]
         createChargeWithToken:paymentMethod.token
         cvv:self.cardTextField.cvc
         capture:YES
         currency:nil
         amount:[[self.amountTextField.text substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""]
         taxAmount:nil
         taxExempt:NO
         tip:nil
         surchargeFeeAmount:nil
         description:@""
         order:nil
         orderId:nil
         poNumber:nil
         metadata:nil
         descriptor:nil
         entryType:nil
         idempotencyKey:nil
         success:^(SPCharge *charge) {
            [self.activityIndicator stopAnimating];
            NSString *success = [NSString
                                 stringWithFormat:@"Amount: $%@\nStatus: %@\nStatus message: "
                                 @"%@\ntxnID #: %@",
                                 charge.amount, charge.status,
                                 charge.statusDescription, charge.id];
            
            [self displayAlertWithTitle:@"Success"
                                message:success
                            restartDemo:TRUE];
        }
         failure:^(SPError *error) {
            [self.activityIndicator stopAnimating];
            NSString *err = [error localizedDescription];
            [self displayAlertWithTitle:@"Error creating Charge"
                                message:err
                            restartDemo:FALSE];
        }];
    }
     failure:^(SPError *error) {
        [self.activityIndicator stopAnimating];
        NSString *err = [error localizedDescription];
        [self displayAlertWithTitle:@"Error creating Charge"
                            message:err
                        restartDemo:FALSE];
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
