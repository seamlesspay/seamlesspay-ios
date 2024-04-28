/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

//@import SeamlessPay;

#import "DetailViewController.h"
#import "Demo-Swift.h"

@interface DetailViewController () <UITextFieldDelegate>
@property(nonatomic, weak) UIButton *payButton;

@end

@implementation DetailViewController

- (void)configureView {
  // Update the user interface for the detail item.

  if ([self.title isEqualToString:@"Authentication"]) {

    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:@"authentication-html"];

    _contentHTML = [[NSString alloc] initWithData:dataAsset.data encoding:NSUTF8StringEncoding];

    NSString *html = [self authContent];

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
    [NSString stringWithFormat:_contentHTML, self.savedCustomerData[@"id"]];

    WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                  configuration:theConfiguration];
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
    (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:_webView];

    [self.webView loadHTMLString:html baseURL:nil];

  } else if ([self.title isEqualToString:@"Update Customer"]) {

    NSDictionary *dict = self.savedCustomerData;

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
                      dict[@"line1"] ?: @"",
                      dict[@"line2"] ?: @"",
                      dict[@"city"] ?: @"",
                      dict[@"country"] ?: @"",
                      dict[@"state"] ?: @"",
                      dict[@"postalCode"] ?: @"",
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
                      stringWithFormat:_contentHTML, [self savedPaymentMethodToken] ?: @""];

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
        [self.singleLineCardFormView clear];
        self.singleLineCardFormView.countryCode = @"US";
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

@end
