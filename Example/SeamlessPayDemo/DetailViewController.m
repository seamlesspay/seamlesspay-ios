/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@import SeamlessPayCore;

#import "DetailViewController.h"
#import "SeamlessPayCore-Swift.h"

@interface DetailViewController () <UITextFieldDelegate>

@property(nonatomic, weak) SPPaymentCardTextField *cardTextField;
@property(nonatomic, weak) UITextField *amountTextField;
@property(nonatomic, weak) UIButton *payButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailViewController

- (void)configureView {
  // Update the user interface for the detail item.

  if ([self.title isEqualToString:@"Authentication"]) {

    NSString *secretKey =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"secretkey"];
    NSString *publishableKey =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"publishableKey"];
    SPEnvironment env = [[NSUserDefaults standardUserDefaults] integerForKey:@"env"];

    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"authentication-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    NSString *html = [self authContentHTMLWithParams:nil
                                           secretKey:secretKey
                                      publishableKey:publishableKey
                                         environment:env];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];

    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    [self.view addSubview:_webView];
    [self.webView loadHTMLString:html baseURL:nil];

  } else if ([self.title isEqualToString:@"Add Credit/Debit Card"]) {

    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"add-credit-debit-card-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];

    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    [self.view addSubview:_webView];
    [self.webView loadHTMLString:_contentHTML baseURL:nil];

  } else if ([self.title isEqualToString:@"Add Gift Card"]) {
    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"add-gift-card-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];

    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    [self.view addSubview:_webView];
    [self.webView loadHTMLString:_contentHTML baseURL:nil];

  } else if ([self.title isEqualToString:@"Add ACH"]) {
    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"add-ach-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];

    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    [self.view addSubview:_webView];
    [self.webView loadHTMLString:_contentHTML baseURL:nil];

  } else if ([self.title isEqualToString:@"Create Customer"]) {

    _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;}input[type="
        @"\"submit\"]{background-color:#40a9ff;color:white;padding:10px "
        @"25px;border:none;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form>Name:<br><input type=\"text\" "
        @"name=\"name\" size=\"36\" required><br>Email:<br><input "
        @"type=\"email\" name=\"email\" size=\"36\" pattern=\"[^ @]*@[^ "
        @"@]*\"><br>Address:<br><input type=\"text\" name=\"address\" "
        @"size=\"36\"><br>Second address:<br><input type=\"text\" "
        @"name=\"address2\" size=\"36\"><br>City:<br><input type=\"text\" "
        @"name=\"city\" size=\"36\"><br>Country (2 characters):<br><input type=\"text\" "
        @"name=\"country\" size=\"36\"><br>State (2 characters):<br><input "
        @"type=\"text\" name=\"state\" size=\"36\"><br>Zip (5 "
        @"characters):<br><input type=\"text\" name=\"zip\" "
        @"size=\"36\"><br>Company name:<br><input type=\"text\" "
        @"name=\"companyName\" size=\"36\"><br>Phone number (10 "
        @"characters):<input type=\"number\" "
        @"name=\"phone\"><br>Website:<br><input type=\"url\" name=\"website\" "
        @"size=\"36\"><br><br><center><input type=\"submit\" "
        @"name=\"createcustomer\" "
        @"value=\"Create\"></center></form><center><!--[RESULTS]--></center></"
        @"body></html>";

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:_contentHTML baseURL:nil];

  } else if ([self.title isEqualToString:@"Retrieve a Customer"]) {

    NSDictionary *dict =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];

    _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;}input[type="
        @"\"submit\"]{background-color:#40a9ff;color:white;padding:10px "
        @"25px;border:none;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form>ID of Customer:<br><input "
        @"type=\"text\" name=\"id\" size=\"36\" value=\"%@\" "
        @"required><br><br><center><input type=\"submit\" "
        @"name=\"retrievecustomer\" "
        @"value=\"Get\"></center></form><center><!--[RESULTS]--></center></"
        @"body></html>";

    NSString *html =
        [NSString stringWithFormat:_contentHTML, dict ? dict[@"customerId"] : @""];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:html baseURL:nil];

  } else if ([self.title isEqualToString:@"Update Customer"]) {

    NSDictionary *dict =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];

    if (!dict) {
      dict = [NSDictionary new];
    }

    _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;}input[type="
        @"\"submit\"]{background-color:#40a9ff;color:white;padding:10px "
        @"25px;border:none;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form>Name:<br><input type=\"text\" "
        @"name=\"name\" value=\"%@\" size=\"36\" required><br>Email:<br><input "
        @"type=\"email\" name=\"email\" value=\"%@\" size=\"36\" pattern=\"[^ "
        @"@]*@[^ @]*\"><br>Address:<br><input type=\"text\" name=\"address\" "
        @"value=\"%@\" size=\"36\"><br>Second address:<br><input type=\"text\" "
        @"name=\"address2\" value=\"%@\" size=\"36\"><br>City:<br><input "
        @"type=\"text\" name=\"city\" value=\"%@\" "
        @"size=\"36\"><br>Country:<br><input type=\"text\" name=\"country\" "
        @"value=\"%@\" size=\"36\"><br>State (2 characters):<br><input "
        @"type=\"text\" name=\"state\" value=\"%@\" size=\"36\"><br>Zip (5 "
        @"characters):<br><input type=\"text\" name=\"zip\" value=\"%@\" "
        @"size=\"36\"><br>Company name:<br><input type=\"text\" "
        @"name=\"companyName\" value=\"%@\" size=\"36\"><br>Phone number (10 "
        @"characters):<input type=\"number\" name=\"phone\" "
        @"value=\"%@\"><br>Website:<br><input type=\"url\" name=\"website\" "
        @"value=\"%@\" size=\"36\"><input type=\"hidden\" name=\"id\" "
        @"value=\"%@\" required><br><br><center><input type=\"submit\" "
        @"name=\"updatecustomer\" "
        @"value=\"Update\"></center></form><center><!--[RESULTS]--></center></"
        @"body></html>";

    NSString *html = [NSString
        stringWithFormat:_contentHTML,
                        dict[@"name"] ?: @"",
                        dict[@"email"] ?: @"",
                        dict[@"address"][@"line1"] ?: @"",
                        dict[@"address"][@"line2"] ?: @"",
                        dict[@"address"][@"city"] ?: @"",
                        dict[@"address"][@"country"] ?: @"",
                        dict[@"address"][@"state"] ?: @"",
                        dict[@"address"][@"postalCode"] ?: @"",
                        dict[@"companyName"] ?: @"",
                        dict[@"phone"] ?: @"",
                        dict[@"website"] ?: @"",
                        dict[@"customerId"] ?: @""];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:html baseURL:nil];

  } else if ([self.title isEqualToString:@"Create a Charge"]) {

    NSDictionary *savedPaymentMethod =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"paymentMethod"];

    _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;}input[type="
        @"\"submit\"]{background-color:#40a9ff;color:white;padding:10px "
        @"25px;border:none;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form>Token:<br><input "
        @"type=\"text\" name=\"token\" size=\"36\" value=\"%@\" "
        @"required><br>CVV:<br><input type=\"number\" "
        @"name=\"cvv\"><br>Amount:<br><input type=\"number\" "
        @"name=\"amount\"><br>Tax amount:<br><input type=\"number\" "
        @"name=\"taxAmount\"><br>Surcharge fee amount:<br><input "
        @"type=\"number\" name=\"surchargeFeeAmount\"><br>TIP:<br><input "
        @"type=\"number\" name=\"tip\"><br>Payment Description:<br><input "
        @"type=\"text\" name=\"description\" size=\"36\"><br>Order "
        @"ID:<br><input type=\"text\" name=\"orderId\" "
        @"size=\"36\"><br>Descriptor (merchant|product|service):<br><input "
        @"type=\"text\" name=\"descriptor\" size=\"36\"><br>Capture :<select "
        @"name=\"capture\"><option>NO</option><option>YES</option></"
        @"select>&nbsp;&nbsp;&nbsp;Tax exempt :<select "
        @"name=\"taxExempt\"><option>NO</option><option>YES</option></"
        @"select><br><center><input type=\"submit\" name=\"createcharge\" "
        @"value=\"Create\"></center></form><center><!--[RESULTS]--></center></"
        @"body></html>";

    NSString *html = [NSString
        stringWithFormat:_contentHTML, savedPaymentMethod
                                           ? savedPaymentMethod[@"token"]
                                           : @""];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:html baseURL:nil];

  } else if ([self.title isEqualToString:@"Retrieve a Charge"]) {

    NSString *chargeId =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"chargeId"];

    _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;}input[type="
        @"\"submit\"]{background-color:#40a9ff;color:white;padding:10px "
        @"25px;border:none;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form>ID of Charge:<br><input "
        @"type=\"text\" name=\"id\" size=\"36\" value=\"%@\" "
        @"required><br><br><center><input type=\"submit\" "
        @"name=\"retrievecharge\" "
        @"value=\"Get\"></center></form><center><!--[RESULTS]--></center></"
        @"body></html>";

    NSString *html = [NSString stringWithFormat:_contentHTML, chargeId ?: @""];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:html baseURL:nil];

  } else if ([self.title isEqualToString:@"Virtual Terminal (CHARGE)"]) {

    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"virtual-terminal-charge-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:_contentHTML baseURL:nil];

  } else if ([self.title isEqualToString:@"Virtual Terminal (ACH)"]) {

    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"virtual-terminal-ach-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:_contentHTML baseURL:nil];
  } else if ([self.title isEqualToString:@"Virtual Terminal (GIFT CARD)"]) {


    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"virtual-terminal-gift-card-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:_contentHTML baseURL:nil];

  } else if ([self.title isEqualToString:@"UI Payment Card Text Field"]) {

    SPPaymentCardTextField *cardTextField =
        [[SPPaymentCardTextField alloc] init];
    cardTextField.postalCodeEntryEnabled = YES;
    cardTextField.countryCode = @"US";
    self.cardTextField = cardTextField;

    UITextField *amountTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 0, 150, 22)];
    amountTextField.text = @"$1.00";
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
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
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

  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  if (self.detailItem) {
    self.title = [self.detailItem description];
    [self configureView];
  }

  self.activityIndicator = [[UIActivityIndicatorView alloc]
                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
  self.activityIndicator.center = self.view.center;
  [self.view addSubview:self.activityIndicator];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSString *)newDetailItem {
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;

    // Update the view.
    [self configureView];
  }
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
        self.cardTextField.postalCodeEntryEnabled =
        YES;
        self.cardTextField.countryCode = @"US";
        self.amountTextField.text = @"0.00";
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
    
    NSString *cardNumber = _cardTextField.cardNumber;
    NSString *exp = _cardTextField.formattedExpirationDate;
    NSString *cvc = _cardTextField.cvc;
    NSString *zip = _cardTextField.postalCode;

    [self.activityIndicator startAnimating];
    
    CFTimeInterval startTime = CACurrentMediaTime();
    // perform some action
    
    SPAddress * billingAddress = [[SPAddress alloc] initWithline1:nil
                                                            line2:nil
                                                             city:nil
                                                          country:nil
                                                            state:nil
                                                       postalCode:zip];
    
    [[SPAPIClient getSharedInstance] tokenizeWithPaymentType:SPPaymentTypeCreditCard
                                               accountNumber:cardNumber
                                                     expDate:exp
                                                         cvv:cvc
                                                 accountType:nil
                                                     routing:nil
                                                         pin:nil
                                              billingAddress:billingAddress
                                                        name:@"Michael Smith"
                                                     success:^(SPPaymentMethod *paymentMethod) {
        if (paymentMethod) {
            
          [[SPAPIClient getSharedInstance] createChargeWithToken:paymentMethod.token
                                                             cvv:cvc
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
                CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
                
                if (charge) {
                    [self.activityIndicator stopAnimating];
                    NSString *success =
                    [NSString stringWithFormat:
                     @"Amount: $%@\nStatus: %@\nStatus message: "
                     @"%@\ntxnID #: %@\nTimeInterval: %f s",
                     charge.amount, charge.status,
                     charge.statusDescription, charge.id,
                     elapsedTime];
                    
                    [self displayAlertWithTitle:@"Success"
                                        message:success
                                    restartDemo:YES];
                }
            }
                                                         failure:^(SPError *error) {
                [self.activityIndicator stopAnimating];
                [self displayAlertWithTitle:@"Error creating Charge"
                                    message:error.localizedDescription
                                restartDemo:NO];
            }];
        }
    }
                                                                failure:^(SPError *error) {
        [self.activityIndicator stopAnimating];
        [self displayAlertWithTitle:@"Error creating token"
                            message:error.localizedDescription
                        restartDemo:NO];
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

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:
(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler([self shouldStartDecidePolicy:[navigationAction request]]);
}

- (BOOL)shouldStartDecidePolicy:(NSURLRequest *)request {

  NSString *str =
      [[[[request.URL.absoluteString stringByRemovingPercentEncoding]
          stringByReplacingOccurrencesOfString:@"="
                                    withString:@"&"]
          stringByReplacingOccurrencesOfString:@"?"
                                    withString:@"&"]
          stringByReplacingOccurrencesOfString:@"+"
                                    withString:@" "];
  NSArray *qa = [str componentsSeparatedByString:@"&"];

  if (qa.count == 1)
    return YES;

  if ([self.detailItem isEqualToString:@"Authentication"]) {

    NSString *publishableKey = qa[2];
    NSString *secretKey = qa[4];
    NSString *envSting = qa[6];
    SPEnvironment env = [self environmentFromString: envSting];

    [[NSUserDefaults standardUserDefaults] setObject:publishableKey
                                              forKey:@"publishableKey"];
    [[NSUserDefaults standardUserDefaults] setObject:secretKey
                                              forKey:@"secretkey"];
    [[NSUserDefaults standardUserDefaults] setInteger:env
                                               forKey:@"env"];


    [[SPAPIClient getSharedInstance] setSecretKey:secretKey
                                   publishableKey:publishableKey
                                      environment:env];

    void (^updateWebView)(NSString *) = ^(NSString *message) {
      NSString *html = [self authContentHTMLWithParams:message
                                             secretKey:secretKey
                                        publishableKey:publishableKey
                                           environment:env];
      [self.webView loadHTMLString:html baseURL:nil];
    };

    [[SPAPIClient getSharedInstance] listChargesWithSuccess:^(SPChargePage *page) {
      if (page) {
        updateWebView(@"Authentication success!");
      }
    }
                                                   failure:^(SPError *error) {
      if (error != nil) {
        NSLog(@"%@", error);
      }
      updateWebView(error.localizedDescription);
    }];

    return NO;
  } else if ([self.detailItem isEqualToString:@"Add Credit/Debit Card"] ||
             [self.detailItem isEqualToString:@"Add Gift Card"] ||
             [self.detailItem isEqualToString:@"Add ACH"]) {

    SPAddress * billingAddress = [[SPAddress alloc] initWithline1:qa[14]
                                                            line2:qa[16]
                                                             city:qa[18]
                                                          country:qa[20]
                                                            state:qa[22]
                                                       postalCode:qa[24]];

    [[SPAPIClient getSharedInstance] tokenizeWithPaymentType:[self paymentTypeFromString:qa[2]]
                                               accountNumber:qa[4]
                                                     expDate:qa[6]
                                                         cvv:qa[8]
                                                 accountType:qa[10]
                                                     routing:qa[8]
                                                         pin:qa[12]
                                              billingAddress:billingAddress
                                                        name:qa[26]
                                                     success:^(SPPaymentMethod * _Nonnull paymentMethod) {

      NSMutableDictionary *pmDict =
      [[paymentMethod dictionary] mutableCopy];

      [[NSUserDefaults standardUserDefaults] setObject:pmDict
                                                forKey:@"paymentMethod"];

      NSString *paymentMethodInfo = [NSString
                                     stringWithFormat:
                                       @"Token info:<br>%@<br>%@<br>%@<br>%@<br>",
                                     paymentMethod.token, paymentMethod.paymentType,
                                     paymentMethod.lastfour ?: @"", paymentMethod.expDate ?: @""];

      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:paymentMethodInfo];

      [self.webView loadHTMLString:html baseURL:nil];

    } failure:^(SPError * _Nonnull error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];
    }];

    return NO;
  } else if ([self.detailItem isEqualToString:@"Create Customer"]) {

    NSDictionary *savedPaymentMethod =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"paymentMethod"];

    NSArray *paymentMethods = savedPaymentMethod
    ? @[ [[SPPaymentMethod alloc]
          initWithDictionary:savedPaymentMethod] ]
    : nil;

    SPAddress * address = [[SPAddress alloc] initWithline1:qa[6]
                                                     line2:qa[8]
                                                      city:qa[10]
                                                   country:qa[12]
                                                     state:qa[14]
                                                postalCode:qa[16]];

    [[SPAPIClient getSharedInstance] createCustomerWithName:qa[2]
                                                      email:qa[4]
                                                    address:address
                                                companyName:qa[18]
                                                      notes:nil
                                                      phone:qa[20]
                                                    website:qa[22]
                                             paymentMethods:paymentMethods
                                                   metadata:@"{\"customOption\":\"example\"}"
                                                    success:^(SPCustomer *customer) {
      if (customer) {

        [[NSUserDefaults standardUserDefaults]
         setObject:[customer dictionary]
         forKey:@"customer"];

        NSString *html = [self.contentHTML
                          stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                          withString:customer.customerId];

        [self.webView loadHTMLString:html baseURL:nil];
      }
    }
                                                    failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];
    }];

    return NO;
  } else if ([self.detailItem isEqualToString:@"Retrieve a Customer"]) {

    [[SPAPIClient getSharedInstance] retrieveCustomerWithId:[qa objectAtIndex:2]
                                                    success:^(SPCustomer *customer) {
      if (customer) {

        [[NSUserDefaults standardUserDefaults]
         setObject:[customer dictionary]
         forKey:@"customer"];

        NSString *html = [self.contentHTML
                          stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                          withString:[NSString stringWithFormat:@"Customer Name: %@", customer.name]];
        html = [NSString stringWithFormat:html, customer.customerId];

        [self.webView loadHTMLString:html baseURL:nil];
      }
    }
                                                    failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];
    }];
    return NO;
  } else if ([self.detailItem isEqualToString:@"Update Customer"]) {

    SPAddress * address = [[SPAddress alloc] initWithline1:qa[6]
                                                     line2:qa[8]
                                                      city:qa[10]
                                                   country:qa[12]
                                                     state:qa[14]
                                                postalCode:qa[16]];

    [[SPAPIClient getSharedInstance] updateCustomerWithId:qa[24]
                                                     name:qa[2]
                                                    email:qa[4]
                                                  address:address
                                              companyName:qa[18]
                                                    notes:nil
                                                    phone:qa[20]
                                                  website:qa[22]
                                           paymentMethods:nil
                                                 metadata:@"{\"customOption\":\"exampleupdate\"}"
                                                  success:^(SPCustomer *customer) {
      if (customer) {

        NSDictionary *dict = [customer dictionary];

        [[NSUserDefaults standardUserDefaults] setObject:dict
                                                  forKey:@"customer"];

        NSString *html = [self.contentHTML
                          stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                          withString:@"Updated success!"];

        html = [NSString stringWithFormat:html,
                customer.name ?: @"",
                customer.email ?: @"",
                customer.address.line1 ?: @"",
                customer.address.line2 ?: @"",
                customer.address.city ?: @"",
                customer.address.country ?: @"",
                customer.address.state ?: @"",
                customer.address.postalCode ?: @"",
                customer.companyName ?: @"",
                customer.phone ?: @"",
                customer.website ?: @"",
                customer.customerId ?: @""];

        [self.webView loadHTMLString:html baseURL:nil];
      }
    }
                                                  failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];
    }];

    return NO;

  } else if ([self.detailItem isEqualToString:@"Create a Charge"]) {

    [[SPAPIClient getSharedInstance] createChargeWithToken:qa[2]
                                                       cvv:qa[4]
                                                   capture:[qa[20] isEqualToString:@"YES"]
                                                  currency:nil
                                                    amount:qa[6]
                                                 taxAmount:qa[8]
                                                 taxExempt:[qa[22] isEqualToString:@"YES"]
                                                       tip:qa[12]
                                        surchargeFeeAmount:qa[10]
                                               description:qa[14]
                                                     order:nil
                                                   orderId:qa[16]
                                                  poNumber:nil
                                                  metadata:nil
                                                descriptor:qa[18]
                                                 entryType:nil
                                            idempotencyKey:nil
                                                   success:^(SPCharge *charge) {
      if (charge) {

        [[NSUserDefaults standardUserDefaults] setObject:charge.id
                                                  forKey:@"chargeId"];

        NSString *html = [self.contentHTML
                          stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                          withString:
                            [NSString
                             stringWithFormat:
                               @"%@<br>%@",
                             charge.id,
                             charge.statusDescription]];
        html = [NSString stringWithFormat:html, qa[2]];
        [self.webView loadHTMLString:html baseURL:nil];
      }
    }
                                                   failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error  localizedDescription]];
      html = [NSString stringWithFormat:html, qa[2]];
      [self.webView loadHTMLString:html baseURL:nil];
    }];

    return NO;

  } else if ([self.title isEqualToString:@"Retrieve a Charge"]) {

    [[SPAPIClient getSharedInstance] retrieveChargeWithId:qa[2]
                                                  success:^(SPCharge *charge) {
      if (charge) {

        NSString *html = [self.contentHTML
                          stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                          withString:
                            [NSString stringWithFormat:
                             @"Charge ID: "
                             @"%@<br>Amount: %@",
                             charge.id,
                             charge.amount]];
        html = [NSString stringWithFormat:html, qa[2]];

        [self.webView loadHTMLString:html baseURL:nil];
      }
    }
                                                  failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error  localizedDescription]];
      html = [NSString stringWithFormat:html, qa[2]];
      [self.webView loadHTMLString:html baseURL:nil];
    }];
    return NO;

  } else if ([self.title isEqualToString:@"Virtual Terminal (CHARGE)"]) {

    [self.activityIndicator startAnimating];

    SPAddress * billingAddress = [[SPAddress alloc] initWithline1:qa[14]
                                                            line2:nil
                                                             city:nil
                                                          country:@"US"
                                                            state:nil
                                                       postalCode:qa[16]];


    [[SPAPIClient getSharedInstance] tokenizeWithPaymentType:SPPaymentTypeCreditCard
                                               accountNumber:qa[8]
                                                     expDate:qa[10]
                                                         cvv:qa[12]
                                                 accountType:nil
                                                     routing:nil
                                                         pin:nil
                                              billingAddress:billingAddress
                                                        name:qa[4]
                                                     success:^(SPPaymentMethod *paymentMethod) {
      if (paymentMethod) {

        [[SPAPIClient getSharedInstance] createChargeWithToken:paymentMethod.token
                                                           cvv:qa[12]
                                                       capture:[qa[2] isEqualToString:@"YES"]
                                                      currency:nil
                                                        amount:qa[6]
                                                     taxAmount:qa[18]
                                                     taxExempt:NO
                                                           tip:nil
                                            surchargeFeeAmount:nil
                                                   description:qa[22]
                                                         order:nil
                                                       orderId:nil
                                                      poNumber:qa[20]
                                                      metadata:nil
                                                    descriptor:nil
                                                     entryType:nil
                                                idempotencyKey:nil
                                                       success:^(SPCharge *charge) {
          if (charge) {
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:
                                [NSString
                                 stringWithFormat:
                                   @"<div "
                                 @"id=\"info\">"
                                 @"Amount: "
                                 @"$%@<br>Status: "
                                 @"%@<br>Status "
                                 @"message: "
                                 @"%@<br>txnID #: "
                                 @"%@</div>",
                                 charge.amount,
                                 charge.status,
                                 charge.statusDescription,
                                 charge.id]];
            [self.webView loadHTMLString:html baseURL:nil];

            [self.activityIndicator stopAnimating];
          }
        }
                                                       failure:^(SPError *error) {
          NSString *html = [self.contentHTML
                            stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                            withString: [error localizedDescription]];
          html = [NSString stringWithFormat:html, qa[2]];
          [self.webView loadHTMLString:html baseURL:nil];

          [self.activityIndicator stopAnimating];
        }];
      }
    }
                                                                failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error
                                    localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];

      [self.activityIndicator stopAnimating];
    }];

    return NO;
  } else if ([self.title isEqualToString:@"Virtual Terminal (ACH)"]) {

    [self.activityIndicator startAnimating];

    SPAddress * billingAddress = [[SPAddress alloc] initWithline1:qa[14]
                                                            line2:nil
                                                             city:qa[16]
                                                          country:qa[22]
                                                            state:qa[18]
                                                       postalCode:qa[20]];


    [[SPAPIClient getSharedInstance] tokenizeWithPaymentType:SPPaymentTypeAch
                                               accountNumber:qa[10]
                                                     expDate:nil
                                                         cvv:nil
                                                 accountType:qa[2]
                                                     routing:qa[8]
                                                         pin:nil
                                              billingAddress:billingAddress
                                                        name:qa[4]
                                                     success:^(SPPaymentMethod *paymentMethod) {
      if (paymentMethod) {

        [[SPAPIClient getSharedInstance] createChargeWithToken:paymentMethod.token
                                                           cvv:nil
                                                       capture:NO
                                                      currency:nil
                                                        amount:qa[12]
                                                     taxAmount:nil
                                                     taxExempt:NO
                                                           tip:nil
                                            surchargeFeeAmount:nil
                                                   description:qa[26]
                                                         order:nil
                                                       orderId:nil
                                                      poNumber:nil
                                                      metadata:nil
                                                    descriptor:nil
                                                     entryType:nil
                                                idempotencyKey:nil
                                                       success:^(SPCharge *charge) {
          if (charge) {

            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:
                                [NSString
                                 stringWithFormat:
                                   @"<div "
                                 @"id=\"info\">"
                                 @"Amount: "
                                 @"$%@<br>Status: "
                                 @"%@<br>Status "
                                 @"message: "
                                 @"%@<br>txnID #: "
                                 @"%@</div>",
                                 charge.amount,
                                 charge.status,
                                 charge.statusDescription,
                                 charge.id]];
            [self.webView loadHTMLString:html baseURL:nil];

            [self.activityIndicator stopAnimating];
          }
        }
                                                       failure:^(SPError *error) {
          NSString *html = [self.contentHTML
                            stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                            withString:[error localizedDescription]];
          html = [NSString stringWithFormat:html, qa[2]];
          [self.webView loadHTMLString:html baseURL:nil];

          [self.activityIndicator stopAnimating];
        }];
      }
    }
                                                                failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error
                                    localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];

      [self.activityIndicator stopAnimating];
    }];

    return NO;
  } else if ([self.title isEqualToString:@"Virtual Terminal (GIFT CARD)"]) {

    [self.activityIndicator startAnimating];

    [[SPAPIClient getSharedInstance] tokenizeWithPaymentType:SPPaymentTypeGiftCard
                                               accountNumber:qa[4]
                                                     expDate:nil
                                                         cvv:nil
                                                 accountType:nil
                                                     routing:nil
                                                         pin:qa[8]
                                              billingAddress:nil
                                                        name:qa[2]
                                                     success:^(SPPaymentMethod *paymentMethod) {
      if (paymentMethod) {

        [[SPAPIClient getSharedInstance] createChargeWithToken:paymentMethod.token
                                                           cvv:nil
                                                       capture:NO
                                                      currency:qa[10]
                                                        amount:qa[6]
                                                     taxAmount:nil
                                                     taxExempt:NO
                                                           tip:nil
                                            surchargeFeeAmount:nil
                                                   description:nil
                                                         order:nil
                                                       orderId:nil
                                                      poNumber:nil
                                                      metadata:nil
                                                    descriptor:nil
                                                     entryType:nil
                                                idempotencyKey:nil
                                                       success:^(SPCharge *charge) {
          if (charge) {

            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:
                                [NSString
                                 stringWithFormat:
                                   @"<div "
                                 @"id=\"info\">"
                                 @"Amount: "
                                 @"$%@<br>Status: "
                                 @"%@<br>Status "
                                 @"message: "
                                 @"%@<br>txnID #: "
                                 @"%@</div>",
                                 charge.amount,
                                 charge.status,
                                 charge.statusDescription,
                                 charge.id]];
            [self.webView loadHTMLString:html baseURL:nil];

            [self.activityIndicator stopAnimating];
          }
        }
                                                       failure:^(SPError *error) {
          NSString *html = [self.contentHTML
                            stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                            withString:[error localizedDescription]];
          html = [NSString stringWithFormat:html, qa[2]];
          [self.webView loadHTMLString:html baseURL:nil];

          [self.activityIndicator stopAnimating];
        }];
      }
    }
                                                     failure:^(SPError *error) {
      NSString *html = [self.contentHTML
                        stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                        withString:[error
                                    localizedDescription]];

      [self.webView loadHTMLString:html baseURL:nil];

      [self.activityIndicator stopAnimating];
    }];

    return NO;
  }

  return YES;
}

// MARK: - EnvironmentParsing
- (SPEnvironment)environmentFromString:(NSString *)string {
  if ([string isEqualToString:@"production"]) {
    return SPEnvironmentProduction;
  } else if ([string isEqualToString:@"sandbox"]) {
    return SPEnvironmentSandbox;
  } else if ([string isEqualToString:@"staging"]) {
    return SPEnvironmentStaging;
  } else if ([string isEqualToString:@"qat"]) {
    return SPEnvironmentQat;
  } else {
    // Handle unrecognized string or return a default value
    return SPEnvironmentSandbox;
  }
}

- (SPPaymentType)paymentTypeFromString:(NSString *)string {
  if ([string isEqualToString:@"credit_card"]) {
    return SPPaymentTypeCreditCard;
  } else if ([string isEqualToString:@"pldebit_card"]) {
    return SPPaymentTypePlDebitCard;
  } else if ([string isEqualToString:@"gift_card"]) {
    return SPPaymentTypeGiftCard;
  } else if ([string isEqualToString:@"ach"]) {
    return SPPaymentTypeAch;
  } else {
    // Handle unrecognized string or return a default value
    return SPPaymentTypeCreditCard;
  }
}

- (NSString *)authContentHTMLWithParams:(NSString *)resultMessage
                              secretKey:(NSString *)secretKey
                         publishableKey:(NSString *)publishableKey
                            environment:(SPEnvironment)environment {
  NSAssert(([self.title isEqualToString:@"Authentication"] && self.contentHTML),
           @"Wrong place to call this function");

  NSString *html = [self.contentHTML copy];
  if (resultMessage) {
    html = [html
            stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
            withString:
              resultMessage];
  }
  html = [NSString stringWithFormat:
          html,
          publishableKey,
          secretKey,
          environment == SPEnvironmentSandbox ? @"selected" : @"",
          environment == SPEnvironmentProduction ? @"selected" : @"",
          environment == SPEnvironmentStaging ? @"selected" : @"",
          environment == SPEnvironmentQat ? @"selected" : @""];
  return html;
}

@end
