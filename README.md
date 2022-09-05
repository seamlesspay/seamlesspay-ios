# SeamlessPayCore

*The Seamless Payments iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app.*

Our framework provides elements that can be used out-of-the-box to collect your users' payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences. Additionally, a low-level `SPAPIClient` is included which corresponds to resources and methods in the Seamless Payments API, so that you can build any custom functionality on top of this layer while still taking advantage of utilities from the `SeamlessPayCore` framework.

## Native UI Elements

`SPPaymentCardTextField` is a text field with similar properties to `UITextField`, but it is specialized for collecting credit/debit card information. It manages multiple `UITextFields` under the hood in order to collect this information seamlessly from users. It's designed to fit on a single line, and from a design perspective can be used anywhere a `UITextField` would be appropriate.

#### Example UI

![image](https://github.com/seamlesspay/seamlesspay-ios/blob/dev/files/card-field.gif)

*Requirements: The SeamlessPay iOS SDK requires Xcode 10.1 or later and is compatible with apps targeting iOS 11 or above.*

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

SeamlessPayCore is available through [CocoaPods](https://cocoapods.org). To install, simply add the following line to your Podfile:

```ruby
pod 'SeamlessPayCore'
```

## Authentication

When your app starts, configure the SDK with your SeamlessPay publishable (you can get it on the API Keys page), so that it can make requests to the SeamlessPay API.

Using only Publishable Key for a single page apps without their own backend. In this case you will be able to do /v1/charge only.
Using a Secret Key allows you using all transaction's methods (e.g. /v1/charge, /v1/refund, /v1/void).

Objective-C:

```objective-c

AppDelegate.m
  #import "AppDelegate.h"
  @import SeamlessPayCore;
  
  @implementation AppDelegate
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
          [[SPAPIClient getSharedInstance]
             setSecretKey:@"sk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
             publishableKey:@"pk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
             apiEndpoint:@"https://sandbox.seamlesspay.com"
             panVaultEndpoint:@"https://sandbox-pan-vault.seamlesspay.com"];
      // do any other necessary launch configuration
      return YES;
  }
  @end

```

Swift:

```swift
import SeamlessPayCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

                SPAPIClient.getSharedInstance().setSecretKey( "sk_XXXXXXXXXXXXXXXXXXXXXXXXXX",
                                         publishableKey: "pk_XXXXXXXXXXXXXXXXXXXXXXXXXX",
                                         apiEndpoint: "https://sandbox.seamlesspay.com",
                                         panVaultEndpoint: "https://sandbox-pan-vault.seamlesspay.com")

        return true
    }
}

```

## Create Payment Form

Securely collect card information on the client with SPPaymentCardTextField, a drop-in UI component provided by the SDK. Create an instance of the card component and a Pay button with the following code:

Objective-C:

```objective-c
CheckoutViewController.m

#import "CheckoutViewController.h"
@import SeamlessPayCore;

@interface CheckoutViewController ()
@property (weak) SPPaymentCardTextField *cardTextField;
@property (weak) UIButton *payButton;
@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    SPPaymentCardTextField *cardTextField = [[SPPaymentCardTextField alloc] init];
    self.cardTextField = cardTextField;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor systemBlueColor];
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    [button setTitle:@"Pay" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    self.payButton = button;
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[cardTextField, button]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.translatesAutoresizingMaskIntoConstraints = FALSE;
    stackView.spacing = 20;
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leftAnchor constraintEqualToSystemSpacingAfterAnchor:self.view.leftAnchor multiplier:2],
        [self.view.rightAnchor constraintEqualToSystemSpacingAfterAnchor:stackView.rightAnchor multiplier:2],
        [stackView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.topAnchor multiplier:20],
    ]];
}

- (void)pay {

    NSString *cardNumber = _cardTextField.cardNumber;
    NSString *exp = _cardTextField.formattedExpirationDate;
    NSString *cvc = _cardTextField.cvc;
    NSString *postalCode = _cardTextField.postalCode;

    NSLog(@"%@ %@ %@ %@",cardNumber,exp,cvc,postalCode);
}
@end
```

Swift:

```swift
CheckoutViewController.swift

import UIKit

import SeamlessPayCore

class ViewController: UIViewController {
    lazy var cardTextField: SPPaymentCardTextField = {
        let cardTextField = SPPaymentCardTextField()
        return cardTextField
    }()

    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 20),
        ])
    }

    @objc
    func pay() {
        // ...
    }
}
```

## Create Payment Method and Charge

When the user taps the pay button, convert the card information collected by STPPaymentCardTextField into a PaymentMethod token. Tokenization ensures that no sensitive card data ever needs to touch your server, so that your integration remains PCI compliant.
After the client passes the token, pass its identifier as the source to create a charge with one SPAPIClient method -createChargeWithToken:

Objective-C:

```objective-c

- (void)pay {

     SPAddress * billingAddress = [[SPAddress alloc]
                                  initWithline1:nil
                                  line2:nil
                                  city:nil
                                  country:nil
                                  state:nil
                                  postalCode:self.cardTextField.postalCode];
    
    [[SPAPIClient getSharedInstance]
     createPaymentMethodWithPaymentType:@"credit_card"
     account:self.cardTextField.cardNumber
     expDate:self.cardTextField.formattedExpirationDate
     cvv:self.cardTextField.cvc
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
         digitalWalletProgramType:nil
         
         success:^(SPCharge *charge) {
 
            NSString *success = [NSString
                                 stringWithFormat:@"Amount: $%@\nStatus: %@\nStatus message: "
                                 @"%@\ntxnID #: %@",
                                 charge.amount, charge.status,
                                 charge.statusDescription, charge.chargeId];
                    NSLog(@"%@", success);
          
        }
         failure:^(SPError *error) {
             NSLog(@"%@", [error errorMessage]);;
        }];
    }
     failure:^(SPError *error) {
        NSLog(@"%@", [error errorMessage]);
    }];
}
```

Swift:

```swift
@objc
    func pay() {
      let billingAddress = SPAddress.init(
            line1: nil,
            line2: nil,
            city: nil,
            country: nil,
            state: nil,
            postalCode: cardTextField.postalCode)
        
        
        SPAPIClient.getSharedInstance().createPaymentMethod(
            withPaymentType: "credit_card",
            account: cardTextField.cardNumber,
            expDate: cardTextField.formattedExpirationDate,
            cvv: self.cardTextField.cvc,
            accountType: nil,
            routing: nil,
            pin: nil,
            billingAddress: billingAddress,
            billingCompanyName: nil,
            accountEmail: nil,
            phoneNumber: nil,
            name: "Name IOS test", customer: nil,
            success: { (paymentMethod: SPPaymentMethod?) in
                
                let token = paymentMethod?.token
                
                SPAPIClient.getSharedInstance().createCharge(
                    withToken: token!,
                    cvv: self.cardTextField.cvc,
                    capture: true, currency: nil,
                    amount: "1",
                    taxAmount: nil,
                    taxExempt: false,
                    tip: nil,
                    surchargeFeeAmount: nil,
                    description: nil,
                    order: nil,
                    orderId: nil,
                    poNumber: nil,
                    metadata: nil,
                    descriptor: nil,
                    entryType: nil,
                    idempotencyKey: nil,
                    digitalWalletProgramType: nil,
                    success: { (charge: SPCharge?) in
                        
                        // Success Charge:
                        print(charge?.chargeId ?? "charge is nil")
                        
                    }, failure: { (error: SPError?) in
                        
                        // Handle the error
                        print(error?.errorMessage ?? "")
                        return
                    }
                )
                
            }, failure: { (error: SPError?) in
                
                // Handle the error
                print(error?.errorMessage ?? "")
                return
            }
        )
    }
    }
```

## Apple Pay and Charge


Objective-C:

```objective-c
CheckoutViewController.m

#import "CheckoutViewController.h"
@import SeamlessPayCore;

@interface CheckoutViewController ()
@end

@implementation CheckoutViewController
- (void)viewDidLoad {
    [super viewDidLoad];
        
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
    [controller dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Payment Authorization Controller Finish");
        
    }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult *result))completion {
    
    [[SPAPIClient getSharedInstance] createTokenWithPayment:payment
                                         merchantIdentifier:@"merchant.com.seamlesspay.sdk"
                                                    success:^(SPPaymentMethod *paymentMethod) {
        if (paymentMethod) {
            
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
                        
                if (charge) {

                    NSString *success =
                    [NSString stringWithFormat:
                     @"Amount: $%@\nStatus: %@\nStatus message: "
                     @"%@\ntxnID #: %@\n",
                     charge.amount, charge.status,
                     charge.statusDescription, charge.chargeId];
                     
                     NSLog(@"%@", success);

                }
            }
                                                           failure:^(SPError *error) {
                         NSLog(@"%@", [error errorMessage]);
            }];
            
            
            completion(
                       [[PKPaymentAuthorizationResult alloc] initWithStatus:(PKPaymentAuthorizationStatusSuccess)
                                                                     errors:nil]
                       );
        }
    }
     
                                                    failure:^(SPError *error) {
        completion(
                   [[PKPaymentAuthorizationResult alloc] initWithStatus:(PKPaymentAuthorizationStatusFailure)
                                                                 errors:@[error]]
                   );
    }];
}


```

Swift:

```swift
import UIKit

import SeamlessPayCore

class ViewController: UIViewController {

    lazy var payButton: PKPaymentButton = {
        let button = SPApplePay.paymentButton(with: PKPaymentButtonStyleWhiteOutline, paymentsUsingNetworks: nil)
        button.addTarget(self, action:button.tag == PKPaymentButtonTypeSetUp ? #selector(applepaysetup) : #selector(applepay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 20),
        ])
    }
    
    @objc
    func applepaysetup() {
        if let url = URL(string: "App-Prefs:root=PASSBOOK") {
            UIApplication.shared.open(url, completionHandler: .none)
        }
    }

    @objc
    func applepay() {
        
         let item = PKPaymentSummaryItem(label: "Test Item description", amount: NSDecimalNumber(string: "1"), type: .final)
         let paymentRequest = SPApplePay.paymentRequest(withMerchantIdentifier: "merchant.MerchantIdentifier", paymentSummaryItems: [item], paymentsUsingNetworks: nil)
         
         let paymentAuthorizationVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationVC.delegate = self
        self.present(paymentAuthorizationVC, animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        print("paymentAuthorizationViewController delegates called")
        
           SPAPIClient.getSharedInstance().createToken(with: payment, merchantIdentifier: "merchant.MerchantIdentifier") {
           
             (paymentMethod: SPPaymentMethod?) in
                
                let token = paymentMethod?.token
                
                SPAPIClient.getSharedInstance().createCharge(
                    withToken: token!,
                    cvv: nil,
                    capture: true, currency: nil,
                    amount: "1",
                    taxAmount: nil,
                    taxExempt: false,
                    tip: nil,
                    surchargeFeeAmount: nil,
                    description: @"Apple Pay Charge",
                    order: nil,
                    orderId: nil,
                    poNumber: nil,
                    metadata: nil,
                    descriptor: nil,
                    entryType: nil,
                    idempotencyKey: nil,
                    digitalWalletProgramType: "APPLE_PAY",
                    success: { (charge: SPCharge?) in
                        
                        // Success Charge:
                        print(charge?.chargeId ?? "charge is nil")
                        
                    }, failure: { (error: SPError?) in
                        
                        // Handle the error
                        print(error?.errorMessage ?? "")
                        return
                    }
                )
                
            }, failure: { (error: SPError?) in
                
                // Handle the error
                print(error?.errorMessage ?? "")
                return
            }
        )
    }
}


```

Start with [**'Demo APP'**](https://github.com/seamlesspay/seamlesspay-ios/tree/dev/Example) for sample on basic setup and usage.


## License

SeamlessPayCore is available under the MIT license. See the LICENSE file for more info.
