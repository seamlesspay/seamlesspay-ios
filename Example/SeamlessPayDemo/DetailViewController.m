/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@import SeamlessPayCore;

#import "DetailViewController.h"

@interface DetailViewController () <UITextFieldDelegate,PKPaymentAuthorizationViewControllerDelegate>

@property(nonatomic, weak) SPPaymentCardTextField *cardTextField;
@property(nonatomic, weak) UITextField *amountTextField;
@property(nonatomic, weak) UIButton *payButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    
    if ([self.title isEqualToString:@"Authentication"]) {
        
        NSString *secretkey =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"secretkey"];
        NSString *publishableKey =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"publishableKey"];
        
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
        @"user-scalable=no\"/></head><body>In order to authenticate your "
        @"account, you must first generate an API Key. Once you've created an "
        @"account, generating an API key is simple:<br><br>Login to your "
        @"Seamless Payments account Dashboard<br>Select 'API Keys' in left "
        @"side bar<br>Click on 'Reveal Secret Key' button<br><br>Your secret "
        @"API key should never be shared publicly or accessible, such as "
        @"committed code on GitHub, client-side code, "
        @"etc.<br><br><br><form>Publishable Key:<br><center><input "
        @"type=\"text\" name=\"publishableKey\" size=\"36\" "
        @"value=\"%@\"></center><br>Secret Key:<br><center><input "
        @"type=\"text\" name=\"secretkey\" size=\"36\" "
        @"value=\"%@\"><br>"
        @"<br><center><input "
        @"type=\"submit\" name=\"authentication\" value=\"Save API "
        @"Keys\"></center></form><center><!--[RESULTS]--></center></body></"
        @"html>";
        
        NSString *html = [NSString
                          stringWithFormat:_contentHTML, publishableKey ?: @"", secretkey ?: @""];
        
        WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                      configuration:theConfiguration];
        _webView.navigationDelegate = self;
        _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        [self.view addSubview:_webView];
        [self.webView loadHTMLString:html baseURL:nil];
        
    } else if ([self.title isEqualToString:@"Add Credit/Debit Card"]) {
        
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
        @"user-scalable=no\"/></head><body>Our stored value API can be used to "
        @"create a variety of integrated applications, such as gift card and "
        @"rewards programs. A stored-value card is a payments card with a "
        @"monetary value stored on the card itself, not in an external account "
        @"maintained by a financial institution.<br><br><br><form>Select "
        @"type:&nbsp;<select "
        @"name=\"txnType\"><option>credit_card</option><option>pldebit_card</"
        @"option></select><br>Account Number:<br><input type=\"number\" "
        @"name=\"accountNumber\" required><br>Expiration Date:<br><input "
        @"type=\"text\" name=\"expDate\" placeholder=\"MM/YY\" required><input "
        @"type=\"text\" name=\"cvv\" placeholder=\"cvv\"><input type=\"hidden\" "
        @"name=\"bankAccountType\"><input type=\"hidden\" "
        @"name=\"pinNumber\"><br>Billing first address:<br><input "
        @"type=\"text\" name=\"billingAddress\" size=\"36\"><br>Billing second "
        @"address:<br><input type=\"text\" name=\"billingAddress2\" "
        @"size=\"36\"><br>Billing city:<br><input type=\"text\" "
        @"name=\"billingCity\" size=\"36\"><br>Billing Country:<br><input "
        @"type=\"text\" name=\"billingCountry\" size=\"36\"><br>Billing State "
        @"(2 characters):<br><input type=\"text\" name=\"billingState\" "
        @"size=\"36\"><br>Billing Zip (5 characters):<br><input type=\"text\" "
        @"name=\"billingZip\" size=\"36\"><br>Billing company name:<br><input "
        @"type=\"text\" name=\"company\" size=\"36\"><br>Account "
        @"email:<br><input type=\"email\" name=\"email\" size=\"36\" "
        @"pattern=\"[^ @]*@[^ @]*\"><br>Name:<input type=\"text\" "
        @"name=\"name\" size=\"36\"><br>Customer name:<input type=\"text\" "
        @"name=\"customer_name\" size=\"36\"><br>Phone number (10 "
        @"characters):<input type=\"number\" "
        @"name=\"phoneNumber\">"
        @"<br><br><center><input type=\"submit\" "
        @"name=\"panvault\" "
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
        
    } else if ([self.title isEqualToString:@"Add Gift Card"]) {
        
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
        @"user-scalable=no\"/></head><body>Our stored value API can be used to "
        @"create a variety of integrated applications, such as gift card and "
        @"rewards programs. A stored-value card is a payments card with a "
        @"monetary value stored on the card itself, not in an external account "
        @"maintained by a financial institution.<br><br><form><input "
        @"type=\"hidden\" name=\"txnType\" value=\"gift_card\"><br>Account "
        @"Number:<br><input type=\"number\" name=\"accountNumber\" "
        @"required><br><input type=\"hidden\" name=\"expDate\"><input "
        @"type=\"hidden\" name=\"routingNumber\"><input type=\"hidden\" "
        @"name=\"bankAccountType\">PIN (6 characters):<br><input "
        @"type=\"number\" name=\"pinNumber\"><br>Billing first "
        @"address:<br><input type=\"text\" name=\"billingAddress\" "
        @"size=\"36\"><br>Billing second address:<br><input type=\"text\" "
        @"name=\"billingAddress2\" size=\"36\"><br>Billing city:<br><input "
        @"type=\"text\" name=\"billingCity\" size=\"36\"><br>Billing "
        @"Country:<br><input type=\"text\" name=\"billingCountry\" "
        @"size=\"36\"><br>Billing State (2 characters):<br><input "
        @"type=\"text\" name=\"billingState\" size=\"36\"><br>Billing Zip (5 "
        @"characters):<br><input type=\"text\" name=\"billingZip\" "
        @"size=\"36\"><br>Billing company name:<br><input type=\"text\" "
        @"name=\"company\" size=\"36\"><br>Account email:<br><input "
        @"type=\"email\" name=\"email\" size=\"36\" pattern=\"[^ @]*@[^ "
        @"@]*\"><br>Name:<input type=\"text\" name=\"name\" "
        @"size=\"36\"><br>Nick name:<input type=\"text\" name=\"nickname\" "
        @"size=\"36\"><br>Phone number (10 characters):<input type=\"number\" "
        @"name=\"phoneNumber\"><br><br><center><input type=\"submit\" "
        @"name=\"panvault\" "
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
        
    } else if ([self.title isEqualToString:@"Add ACH"]) {
        
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
        @"user-scalable=no\"/></head><body>Our stored value API can be used to "
        @"create a variety of integrated applications, such as gift card and "
        @"rewards programs. A stored-value card is a payments card with a "
        @"monetary value stored on the card itself, not in an external account "
        @"maintained by a financial institution.<br><br><form><input "
        @"type=\"hidden\" name=\"txnType\" value=\"ach\"><br>Account "
        @"Number:<br><input type=\"number\" name=\"accountNumber\" "
        @"required><br><input type=\"hidden\" name=\"expDate\">Routing number "
        @"(9 characters):<br><input type=\"number\" name=\"routingNumber\" "
        @"required><br>Select bank account type:&nbsp;<select "
        @"name=\"bankAccountType\"><option>Checking</option><option>Savings</"
        @"option></select><input type=\"hidden\" "
        @"name=\"pinNumber\"><br>Billing first address:<br><input "
        @"type=\"text\" name=\"billingAddress\" size=\"36\"><br>Billing second "
        @"address:<br><input type=\"text\" name=\"billingAddress2\" "
        @"size=\"36\"><br>Billing city:<br><input type=\"text\" "
        @"name=\"billingCity\" size=\"36\"><br>Billing Country:<br><input "
        @"type=\"text\" name=\"billingCountry\" size=\"36\"><br>Billing State "
        @"(2 characters):<br><input type=\"text\" name=\"billingState\" "
        @"size=\"36\"><br>Billing Zip (5 characters):<br><input type=\"text\" "
        @"name=\"billingZip\" size=\"36\"><br>Billing company name:<br><input "
        @"type=\"text\" name=\"company\" size=\"36\"><br>Account "
        @"email:<br><input type=\"email\" name=\"email\" size=\"36\" "
        @"pattern=\"[^ @]*@[^ @]*\"><br>Name:<input type=\"text\" "
        @"name=\"name\" size=\"36\"><br>Nick name:<input type=\"text\" "
        @"name=\"nickname\" size=\"36\"><br>Phone number (10 "
        @"characters):<input type=\"number\" "
        @"name=\"phoneNumber\"><br><br><center><input type=\"submit\" "
        @"name=\"panvault\" "
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
        
        _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;border-color:#"
        @"cccccc;}input[type=\"submit\"]{background-color:#40a9ff;color:white;"
        @"padding:10px "
        @"25px;border:none;}#info{padding:10px;margin:5px;background-color:#"
        @"e8e8e8;font-size:10pt;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form><table><tr><td>Type:</"
        @"td><td><select name=\"capture\"><option "
        @"value=\"YES\">Charge</option><option value=\"NO\">Auth "
        @"Only</option></select></td></tr><tr><td>Name:</td><td><input "
        @"type=\"text\" name=\"name\"></td></tr><tr><td>Amount:</td><td><input "
        @"type=\"number\" name=\"amount\" required></td></tr><tr><td>Card "
        @"Number:</td><td><input type=\"number\" name=\"cardnumber\" "
        @"required></td></tr><tr><td>Exp:</td><td><input type=\"text\" "
        @"name=\"expDate\" placeholder=\"MM/YY\" "
        @"required></td></tr><tr><td>cvv:</td><td><input type=\"number\" "
        @"name=\"cvv\" placeholder=\"123\"></td></tr><tr><td>Billing "
        @"Street:</td><td><input type=\"text\" "
        @"name=\"billingAddress\"></td></tr><tr><td>Billing "
        @"Zip:</td><td><input type=\"number\" name=\"billingZip\" "
        @"placeholder=\"12345\"></td></tr><tr><td>Tax Amount:</td><td><input "
        @"type=\"number\" name=\"taxAmount\"></td></tr><tr><td>PO "
        @"#:</td><td><input type=\"text\" "
        @"name=\"poNumber\"></td></tr><tr><td>Description:</td><td><input "
        @"type=\"text\" "
        @"name=\"description\"></td></tr><tr><td>Email:</td><td><input "
        @"type=\"email\" name=\"email\"></td></tr></table><br><br><center><input type=\"submit\" "
        @"name=\"vtcharge\" "
        @"value=\"Process\"></center></form><!--[RESULTS]--></body></html>";
        
        WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                      configuration:theConfiguration];
        _webView.navigationDelegate = self;
        _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:_webView];
        
        [self.webView loadHTMLString:_contentHTML baseURL:nil];
        
    } else if ([self.title isEqualToString:@"Virtual Terminal (ACH)"]) {
        
        _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;border-color:#"
        @"cccccc;}input[type=\"submit\"]{background-color:#40a9ff;color:white;"
        @"padding:10px "
        @"25px;border:none;}#info{padding:10px;margin:5px;background-color:#"
        @"e8e8e8;font-size:10pt;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form><table><tr><td>Account "
        @"Type:</td><td><select "
        @"name=\"bankAccountType\"><option>Checking</option><option>Savings</"
        @"option></select></td></tr><tr><td>Name:</td><td><input type=\"text\" "
        @"name=\"name\"><tr><td>Company:</td><td><input type=\"text\" "
        @"name=\"company\"></td></tr><tr><td>Routing number :</td><td><input "
        @"type=\"number\" name=\"routingNumber\" "
        @"required></td></tr><tr><td>Account Number:</td><td><input "
        @"type=\"number\" name=\"accountNumber\" "
        @"required></td></tr><tr><td>Amount:</td><td><input type=\"number\" "
        @"name=\"amount\" required></td></tr><tr><td>Billing "
        @"Address:</td><td><input type=\"text\" "
        @"name=\"billingAddress\"></td></tr><tr><td>Billing "
        @"City:</td><td><input type=\"text\" "
        @"name=\"billingCity\"></td></tr><tr><td>Billing State:</td><td><input "
        @"type=\"text\" name=\"billingState\"></td></tr><tr><td>Billing "
        @"Zip:</td><td><input type=\"number\" "
        @"name=\"billingZip\"></td></tr><tr><td>Billing "
        @"Country:</td><td><input type=\"text\" "
        @"name=\"billingCountry\"></td></tr><tr><td>Phone "
        @"Number:</td><td><input type=\"number\" "
        @"name=\"phone\"></td></tr><tr><td>Description:</td><td><input "
        @"type=\"text\" "
        @"name=\"description\"></td></tr><tr><td>Email:</td><td><input "
        @"type=\"email\" name=\"email\"></td></tr></table><br><br><center><input type=\"submit\" "
        @"name=\"vtcharge\" "
        @"value=\"Process\"></center></form><!--[RESULTS]--></body></html>";
        
        WKWebViewConfiguration *theConfiguration = [WKWebViewConfiguration new];
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame
                                      configuration:theConfiguration];
        _webView.navigationDelegate = self;
        _webView.autoresizingMask =
        (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:_webView];
        
        [self.webView loadHTMLString:_contentHTML baseURL:nil];
    } else if ([self.title isEqualToString:@"Virtual Terminal (GIFT CARD)"]) {
        
        _contentHTML =
        @"<html><head><style "
        @"type=\"text/"
        @"css\">html{padding:5px;font-family:Verdana;font-size:13pt;}body{"
        @"background-color:#f8f8f8;}input,select{background-color:white;-"
        @"webkit-appearance: "
        @"none;border-radius:2px;font-size:12pt;padding:4px;border-color:#"
        @"cccccc;}input[type=\"submit\"]{background-color:#40a9ff;color:white;"
        @"padding:10px "
        @"25px;border:none;}#info{padding:10px;margin:5px;background-color:#"
        @"e8e8e8;font-size:10pt;}</style><meta name=\"viewport\" "
        @"content=\"initial-scale=1, maximum-scale=1.0, "
        @"user-scalable=no\"/></head><body><form><table><tr><td>Name:</"
        @"td><td><input type=\"text\" name=\"name\"></td></tr><tr><td>Card "
        @"number :</td><td><input type=\"number\" name=\"accountNumber\" "
        @"required></td></tr><tr><td>Amount:</td><td><input type=\"number\" "
        @"name=\"amount\" required></td></tr><tr><td>PIN:</td><td><input "
        @"type=\"number\" name=\"pin\"></td></tr><tr><td>Currency "
        @":</td><td><select "
        @"name=\"currency\"><option>USD</option><option>CAD</option></select></"
        @"td></tr><tr><td>Email:</td><td><input type=\"email\" "
        @"name=\"email\"></td></tr></table><br><br><center><input type=\"submit\" "
        @"name=\"vtcharge\" "
        @"value=\"Process\"></center></form><!--[RESULTS]--></body></html>";
        
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
        
    } else if ([self.title isEqualToString:@"Apple Pay"]) {
        
        
        PKPaymentButton *button = [SPApplePay paymentButtonWithStyle:PKPaymentButtonStyleWhiteOutline paymentsUsingNetworks:nil];
        
        [button addTarget:self
                   action:button.tag == PKPaymentButtonTypeSetUp ? @selector(applepaysetup) : @selector(applepay)
         forControlEvents:UIControlEventTouchUpInside];
        self.payButton = button;
        
        UILabel *infoLbel = [[UILabel alloc] init];
        infoLbel.text = @"Payable: $1.0";
        
        UIStackView *stackView = [[UIStackView alloc]
                                  initWithArrangedSubviews:@[ infoLbel, button ]];
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

- (void)applepaysetup {
    NSURL* url = [NSURL URLWithString:@"App-Prefs:root=PASSBOOK"];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
}

- (void)applepay {
    
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem
                                  summaryItemWithLabel:@"Test Item description"
                                  amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
    
    PKPaymentRequest *paymentRequest = [SPApplePay paymentRequestWithMerchantIdentifier:@"merchant.com.seamlesspay.sdk"
                                                                    paymentSummaryItems:@[item]
                                                                  paymentsUsingNetworks:nil];
    
    PKPaymentAuthorizationViewController *paymentAuthorizationVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    
    paymentAuthorizationVC.delegate = self;
    [self presentViewController:paymentAuthorizationVC
                       animated:YES
                     completion:nil];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    // NSLog(@"\n<---- %@ ---->", @"Payment Authorization Controller Finish");
    [controller dismissViewControllerAnimated:YES completion:^{
        [self displayAlertWithTitle:@"Payment Authorization Controller Finish"
                            message:@""
                        restartDemo:NO];    }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult *result))completion {
    
    //   NSLog(@"\n<---- %@ ---->", @"Payment Authorization");
    
    [[SPAPIClient getSharedInstance] createTokenWithPayment:payment
                                         merchantIdentifier:@"merchant.com.seamlesspay.sdk"
                                                    success:^(SPPaymentMethod *paymentMethod) {
        if (paymentMethod) {
            
            //          NSLog(@"\n%@", @"END TOKEN--->");
            //          NSLog(@"\n%@", [paymentMethod dictionary]);
            //          NSLog(@"\n%@", @"SART CHARGE--->");
            
            CFTimeInterval startTime = CACurrentMediaTime();
            
            [[SPAPIClient getSharedInstance] createChargeWithToken:paymentMethod.token
                                                               cvv:nil
                                                           capture:YES
                                                          currency:nil
                                                            amount:@"1"
                                                         taxAmount:nil
                                                         taxExempt:NO
                                                               tip:nil
                                                surchargeFeeAmount:nil
                                                       description:@"Apple Pay Charge"
                                                             order:nil
                                                           orderId:nil
                                                          poNumber:nil
                                                          metadata:nil
                                                        descriptor:nil
                                                         entryType:nil
                                                    idempotencyKey:nil
                                          digitalWalletProgramType:@"APPLE_PAY"
             
                                                           success:^(SPCharge *charge) {
                CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
                
                if (charge) {
                    // NSLog(@"%@", @"END CHARGE--->");
                    [self.activityIndicator stopAnimating];
                    NSString *success =
                    [NSString stringWithFormat:
                     @"Amount: $%@\nStatus: %@\nStatus message: "
                     @"%@\ntxnID #: %@\nTimeInterval: %f s",
                     charge.amount, charge.status,
                     charge.statusDescription, charge.chargeId,
                     elapsedTime];
                    
                    [self displayAlertWithTitle:@"Success"
                                        message:success
                                    restartDemo:YES];
                }
            }
                                                           failure:^(SPError *error) {
                // NSLog(@"%@", error.errors);
                [self.activityIndicator stopAnimating];
                [self displayAlertWithTitle:@"Error creating Charge"
                                    message:error.errorMessage
                                restartDemo:NO];
            }];
            
            
            completion(
                       [[PKPaymentAuthorizationResult alloc] initWithStatus:(PKPaymentAuthorizationStatusSuccess)
                                                                     errors:nil]
                       );
        }
    }
     
                                                    failure:^(SPError *error) {
        //  NSLog(@"\n%@", error.errors);
        completion(
                   [[PKPaymentAuthorizationResult alloc] initWithStatus:(PKPaymentAuthorizationStatusFailure)
                                                                 errors:@[error]]
                   );
    }];
}

- (void)pay {
    
    NSString *cardNumber = _cardTextField.cardNumber;
    NSString *exp = _cardTextField.formattedExpirationDate;
    NSString *cvc = _cardTextField.cvc;
    NSString *zip = _cardTextField.postalCode;
    
    //  NSLog(@"%@ %@ %@ %@", cardNumber, exp, cvc, zip);
    //
    //  NSLog(@"%@", @"SART TOKEN--->");
    
    [self.activityIndicator startAnimating];
    
    CFTimeInterval startTime = CACurrentMediaTime();
    // perform some action
    
    SPAddress * billingAddress = [[SPAddress alloc] initWithline1:nil
                                                            line2:nil
                                                             city:nil
                                                          country:nil
                                                            state:nil
                                                       postalCode:zip];
    
    [[SPAPIClient getSharedInstance] createPaymentMethodWithPaymentType:@"credit_card"
                                                                account:cardNumber
                                                                expDate:exp
                                                                    cvv:cvc
                                                            accountType:nil
                                                                routing:nil
                                                                    pin:nil
                                                         billingAddress:billingAddress
                                                     billingCompanyName:nil
                                                           accountEmail:nil
                                                            phoneNumber:nil
                                                                   name:@"Name IOS test"
                                                               customer:nil
                                                                success:^(SPPaymentMethod *paymentMethod) {
        if (paymentMethod) {
            
            //          NSLog(@"%@", @"END TOKEN--->");
            //          NSLog(@"%@", [paymentMethod dictionary]);
            //          NSLog(@"%@", @"SART CHARGE--->");
            
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
                                          digitalWalletProgramType:nil
             
                                                           success:^(SPCharge *charge) {
                CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
                
                if (charge) {
                    // NSLog(@"%@", @"END CHARGE--->");
                    [self.activityIndicator stopAnimating];
                    NSString *success =
                    [NSString stringWithFormat:
                     @"Amount: $%@\nStatus: %@\nStatus message: "
                     @"%@\ntxnID #: %@\nTimeInterval: %f s",
                     charge.amount, charge.status,
                     charge.statusDescription, charge.chargeId,
                     elapsedTime];
                    
                    [self displayAlertWithTitle:@"Success"
                                        message:success
                                    restartDemo:YES];
                }
            }
                                                           failure:^(SPError *error) {
                // NSLog(@"%@", error.errors);
                [self.activityIndicator stopAnimating];
                [self displayAlertWithTitle:@"Error creating Charge"
                                    message:error.errorMessage
                                restartDemo:NO];
            }];
        }
    }
                                                                failure:^(SPError *error) {
        // NSLog(@"%@", error.errors);
        [self.activityIndicator stopAnimating];
        [self displayAlertWithTitle:@"Error creating token"
                            message:error.errorMessage
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
    
    // NSLog(@"%@", request.URL.absoluteString);
    
    NSString *str =
    [[[[request.URL.absoluteString stringByRemovingPercentEncoding]
       stringByReplacingOccurrencesOfString:@"="
       withString:@"&"]
      stringByReplacingOccurrencesOfString:@"?"
      withString:@"&"]
     stringByReplacingOccurrencesOfString:@"+"
     withString:@" "];
    NSArray *qa = [str componentsSeparatedByString:@"&"];
    
    // NSLog(@"%@", qa);
    
    if (qa.count == 1)
        return YES;
    
    if ([self.detailItem isEqualToString:@"Authentication"]) {
        
        NSString *publishableKey = qa[2];
        NSString *secretkey = qa[4];
  
        
        [[NSUserDefaults standardUserDefaults] setObject:publishableKey
                                                  forKey:@"publishableKey"];
        [[NSUserDefaults standardUserDefaults] setObject:secretkey
                                                  forKey:@"secretkey"];
       
        
        [[SPAPIClient getSharedInstance]
         setSecretKey:secretkey
         publishableKey:publishableKey
         apiEndpoint:@"https://api.seamlesspay.io"
         panVaultEndpoint:@"https://pan-vault.l1.seamlesspay.io"];
        
        
        [[SPAPIClient getSharedInstance] listChargesWithParams:@{}
                                                       success:^(NSDictionary *dict) {
            // NSLog(@"%@", dict);
            
            if (dict) {
                NSString *html = [self.contentHTML
                                  stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                                  withString:
                                      @"Authentication success!"];
                html = [NSString stringWithFormat:html, publishableKey ?: @"",
                        secretkey ?: @"", @"" ];
                [self.webView loadHTMLString:html baseURL:nil];
            }
        }
                                                       failure:^(SPError *error) {
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error
                                          errorMessage]];
            html = [NSString stringWithFormat:html, publishableKey ?: @"",
                    secretkey ?: @"", @""];
            [self.webView loadHTMLString:html baseURL:nil];
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
        
        SPCustomer * customer = [[SPCustomer alloc] initWithName:qa[32]
                                                           email:nil
                                                           phone:nil
                                                     companyName:nil
                                                           notes:nil
                                                         website:nil
                                                        metadata:nil
                                                         address:nil
                                                  paymentMethods:nil];
        
        
        [[SPAPIClient getSharedInstance] createPaymentMethodWithPaymentType:qa[2]
                                                                    account:qa[4]
                                                                    expDate:qa[6]
                                                                        cvv:qa[8]
                                                                accountType:qa[10]
                                                                    routing:qa[8]
                                                                        pin:qa[12]
                                                             billingAddress:billingAddress
                                                         billingCompanyName:qa[26]
                                                               accountEmail:qa[28]
                                                                phoneNumber:qa[34]
                                                                       name:qa[30]
                                                                   customer:customer
                                                                    success:^(SPPaymentMethod * _Nonnull paymentMethod) {
            
            // NSLog(@"SPPaymentMethod: %@", [paymentMethod dictionary] );
            
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
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error errorMessage]];
            
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
            
            // NSLog(@"%@", customer);
            
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
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error errorMessage]];
            
            [self.webView loadHTMLString:html baseURL:nil];
        }];
        
        return NO;
    } else if ([self.detailItem isEqualToString:@"Retrieve a Customer"]) {
        
        [[SPAPIClient getSharedInstance] retrieveCustomerWithId:[qa objectAtIndex:2]
                                                        success:^(SPCustomer *customer) {
            // NSLog(@"%@", customer);
            
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
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error
                                          errorMessage]];
            
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
            // NSLog(@"%@", customer);
            
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
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error errorMessage]];
            
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
                                      digitalWalletProgramType:nil
         
         
                                                       success:^(SPCharge *charge) {
            if (charge) {
                
                [[NSUserDefaults standardUserDefaults] setObject:charge.chargeId
                                                          forKey:@"chargeId"];
                
                NSString *html = [self.contentHTML
                                  stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                                  withString:
                                      [NSString
                                       stringWithFormat:
                                           @"%@<br>%@",
                                       charge.chargeId,
                                       charge.statusDescription]];
                html = [NSString stringWithFormat:html, qa[2]];
                [self.webView loadHTMLString:html baseURL:nil];
            }
        }
                                                       failure:^(SPError *error) {
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error  errorMessage]];
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
                                       charge.chargeId,
                                       charge.amount]];
                html = [NSString stringWithFormat:html, qa[2]];
                
                [self.webView loadHTMLString:html baseURL:nil];
            }
        }
                                                      failure:^(SPError *error) {
            // NSLog(@"%@", error);
            NSString *html = [self.contentHTML
                              stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                              withString:[error  errorMessage]];
            html = [NSString stringWithFormat:html, qa[2]];
            [self.webView loadHTMLString:html baseURL:nil];
        }];
        return NO;
        
    } else if ([self.title isEqualToString:@"Virtual Terminal (CHARGE)"]) {
        
        // NSLog(@"%@", @"SART TOKEN--->");
        
        [self.activityIndicator startAnimating];
        
        SPAddress * billingAddress = [[SPAddress alloc] initWithline1:qa[14]
                                                                line2:nil
                                                                 city:nil
                                                              country:@"US"
                                                                state:nil
                                                           postalCode:qa[16]];
        
        
        [[SPAPIClient getSharedInstance] createPaymentMethodWithPaymentType:@"credit_card"
                                                                    account:qa[8]
                                                                    expDate:qa[10]
                                                                        cvv:qa[12]
                                                                accountType:nil
                                                                    routing:nil
                                                                        pin:nil
                                                             billingAddress:billingAddress
                                                         billingCompanyName:nil
                                                               accountEmail:qa[24]
                                                                phoneNumber:nil
                                                                       name:qa[4]
                                                                   customer:nil
         
                                                                    success:^(SPPaymentMethod *paymentMethod) {
            if (paymentMethod) {
                
                // NSLog(@"%@", @"END TOKEN--->");
                // NSLog(@"%@", [paymentMethod dictionary]);
                // NSLog(@"%@", @"SART CHARGE--->");
                
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
                                              digitalWalletProgramType:nil
                 
                                                               success:^(SPCharge *charge) {
                    if (charge) {
                        // NSLog(@"%@", @"END CHARGE--->");
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
                                               charge.chargeId]];
                        [self.webView loadHTMLString:html baseURL:nil];
                        
                        [self.activityIndicator stopAnimating];
                    }
                }
                                                               failure:^(SPError *error) {
                    // NSLog(@"%@", error);
                    NSString *html = [self.contentHTML
                                      stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                                      withString:
                                          [error errorMessage]];
                    html = [NSString stringWithFormat:html, qa[2]];
                    [self.webView loadHTMLString:html baseURL:nil];
                    
                    [self.activityIndicator stopAnimating];
                }];
            }
        }
                                                                    failure:^(SPError *error) {
            // NSLog(@"%@", error);
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
        
        
        [[SPAPIClient getSharedInstance] createPaymentMethodWithPaymentType:@"ach"
                                                                    account:qa[10]
                                                                    expDate:nil
                                                                        cvv:nil
                                                                accountType:qa[2]
                                                                    routing:qa[8]
                                                                        pin:nil
                                                             billingAddress:billingAddress
                                                         billingCompanyName:qa[6]
                                                               accountEmail:qa[28]
                                                                phoneNumber:qa[24]
                                                                       name:qa[4]
                                                                   customer:nil
         
                                                                    success:^(SPPaymentMethod *paymentMethod) {
            if (paymentMethod) {
                
                //  NSLog(@"%@", [paymentMethod dictionary]);
                
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
                                              digitalWalletProgramType:nil
                 
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
                                               charge.chargeId]];
                        [self.webView loadHTMLString:html baseURL:nil];
                        
                        [self.activityIndicator stopAnimating];
                    }
                }
                                                               failure:^(SPError *error) {
                    // NSLog(@"%@", error);
                    NSString *html = [self.contentHTML
                                      stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                                      withString:[error errorMessage]];
                    html = [NSString stringWithFormat:html, qa[2]];
                    [self.webView loadHTMLString:html baseURL:nil];
                    
                    [self.activityIndicator stopAnimating];
                }];
            }
        }
                                                                    failure:^(SPError *error) {
            // NSLog(@"%@", error);
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
        
        [[SPAPIClient getSharedInstance] createPaymentMethodWithPaymentType:@"gift_card"
                                                                    account:qa[4]
                                                                    expDate:nil
                                                                        cvv:nil
                                                                accountType:nil
                                                                    routing:nil
                                                                        pin:qa[8]
                                                             billingAddress:nil
                                                         billingCompanyName:nil
                                                               accountEmail:qa[12]
                                                                phoneNumber:nil
                                                                       name:qa[2]
                                                                   customer:nil
         
                                                                    success:^(SPPaymentMethod *paymentMethod) {
            if (paymentMethod) {
                
                //   NSLog(@"%@", [paymentMethod dictionary]);
                
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
                                              digitalWalletProgramType:nil
                 
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
                                               charge.chargeId]];
                        [self.webView loadHTMLString:html baseURL:nil];
                        
                        [self.activityIndicator stopAnimating];
                    }
                }
                                                               failure:^(SPError *error) {
                    // NSLog(@"%@", error);
                    NSString *html = [self.contentHTML
                                      stringByReplacingOccurrencesOfString:@"<!--[RESULTS]-->"
                                      withString:[error errorMessage]];
                    html = [NSString stringWithFormat:html, qa[2]];
                    [self.webView loadHTMLString:html baseURL:nil];
                    
                    [self.activityIndicator stopAnimating];
                }];
            }
        }
                                                                    failure:^(SPError *error) {
            // NSLog(@"%@", error);
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

@end
