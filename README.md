# SeamlessPayCore

*The Seamless Payments iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app.*

Our framework provides elements that can be used out-of-the-box to collect your users' payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences. Additionally, a low-level `APIClient` is included which corresponds to resources and methods in the Seamless Payments API, so that you can build any custom functionality on top of this layer while still taking advantage of utilities from the `SeamlessPayCore` framework.

## Native UI Elements

`SPPaymentCardTextField` is a text field with similar properties to `UITextField`, but it is specialized for collecting credit/debit card information. It manages multiple `UITextFields` under the hood in order to collect this information seamlessly from users. It's designed to fit on a single line, and from a design perspective can be used anywhere a `UITextField` would be appropriate.

#### Example UI

![image](https://github.com/seamlesspay/seamlesspay-ios/blob/dev/files/card-field.gif)

*Requirements: The SeamlessPay iOS SDK requires Xcode 10.1 or later and is compatible with apps targeting iOS 11 or above.*

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods
To install, add the following line to your Podfile:

```ruby
pod 'SeamlessPayCore'
```

### SPM
Add the package to your Xcode project:
```ruby
https://github.com/seamlesspay/seamlesspay-ios.git
```

## Authentication

When your app starts, configure the SDK with your SeamlessPay publishable (you can get it on the API Keys page), so that it can make requests to the SeamlessPay API.

Using only Publishable Key for a single page apps without their own backend. In this case you will be able to do /charge only.
Using a Secret Key allows you using all transaction's methods (e.g. /charge, /refund, /void).

Swift:

```swift
import SeamlessPayCore
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    APIClient.shared.set(
      secretKey: "sk_XXXXXXXXXXXXXXXXXXXXXXXXXX",
      publishableKey: "pk_XXXXXXXXXXXXXXXXXXXXXXXXXX",
      environment: .sandbox
    )

    return true
  }
}
```

## Create Payment Form

Securely collect card information on the client with SPPaymentCardTextField, a drop-in UI component provided by the SDK. Create an instance of the card component and a Pay button with the following code:

Swift:
```swift
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
      stackView.leftAnchor.constraint(
        equalToSystemSpacingAfter: view.leftAnchor,
        multiplier: 2
      ),
      view.rightAnchor.constraint(
        equalToSystemSpacingAfter: stackView.rightAnchor,
        multiplier: 2
      ),
      stackView.topAnchor.constraint(
        equalToSystemSpacingBelow: view.topAnchor,
        multiplier: 20
      ),
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
After the client passes the token, pass its identifier as the source to create a charge with one `APIClient` function `createCharge(token:cvv:...`

Swift:
```swift
  func pay() {
    let billingAddress = Address(
      line1: nil,
      line2: nil,
      city: nil,
      country: nil,
      state: nil,
      postalCode: cardTextField.postalCode
    )

    APIClient.shared.tokenize(
      paymentType: .creditCard,
      accountNumber: cardTextField.cardNumber ?? .init(),
      expDate: .init(
        month: cardTextField.expirationMonth,
        year: cardTextField.expirationYear
      ),
      cvv: cardTextField.cvc,
      billingAddress: billingAddress,
      name: "Michael Smith"
    ) { result in
      switch result {
      case let .success(paymentMethod):
        let token = paymentMethod.token

        APIClient.shared.createCharge(
          token: token!,
          cvv: self.cardTextField.cvc,
          capture: true,
          amount: "1",
          taxExempt: false
        ) { result in
          switch result {
          case let .success(charge):
            // Success Charge:
            print(charge.id)
          case let .failure(error):
            // Handle the error
            print(error.localizedDescription)
            return
          }
        }
      case let .failure(error):
        // Handle the error
        print(error.localizedDescription)
      }
    }
  }
```


Start with [**'Demo APP'**](https://github.com/seamlesspay/seamlesspay-ios/tree/dev/Example) for sample on basic setup and usage.


## License

SeamlessPayCore is available under the MIT license. See the LICENSE file for more info.
