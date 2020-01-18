# SeamlessPayCore

*The Seamless Payments iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app.*

Our framework provides elements that can be used out-of-the-box to collect your users' payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences. Additionally, a low-level `SPAPIClient` is included which corresponds to resources and methods in the Seamless Payments API, so that you can build any custom functionality on top of this layer while still taking advantage of utilities from the `SeamlessPayCore` framework.


## Native UI Elements

`SPPaymentCardTextField` is a text field with similar properties to `UITextField`, but it is specialized for collecting credit/debit card information. It manages multiple `UITextFields` under the hood in order to collect this information seamlessly from users. It's designed to fit on a single line, and from a design perspective can be used anywhere a `UITextField` would be appropriate.

#### Example UI

![image](https://rc-docs.seamlesspay.com/images/card-field.gif)


*Requirements: The SeamlessPay iOS SDK requires Xcode 10.1 or later and is compatible with apps targeting iOS 10 or above.*

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SeamlessPayCore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SeamlessPayCore'
```

## Author

Seamless Payments: info@seamlesspay.com

## License

SeamlessPayCore is available under the MIT license. See the LICENSE file for more info.
