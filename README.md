# ⚡️ SeamlessPay for iOS

*The Seamless Payments iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app.*

Our framework provides elements that can be used out-of-the-box to collect your users' payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences. Additionally, a low-level `SPAPIClient` is included which corresponds to resources and methods in the Seamless Payments API, so that you can build any custom functionality on top of this layer while still taking advantage of utilities from the `SeamlessPayCore` framework.

## Native UI Elements

`SPPaymentCardTextField` is a text field with similar properties to `UITextField`, but it is specialized for collecting credit/debit card information. It manages multiple `UITextFields` under the hood in order to collect this information seamlessly from users. It's designed to fit on a single line, and from a design perspective can be used anywhere a `UITextField` would be appropriate.

#### Example UI

![image](https://rc-docs.seamlesspay.com/images/card-field.gif)

## Usage

*Requirements: The SeamlessPay iOS SDK requires Xcode 10.1 or later and is compatible with apps targeting iOS 10 or above.*

1. Clone framework repo `git clone https://github.com/seamlesspay/ios-sdk.git`
2. Checkout the appropriate release `git checkout release_1.0.1` (where "1.0.1" is the version you want to use)
3. In XCode, select your project file, then right click and add `SeamlessPayCore.xcodeproj`
4. In XCode's "Build Phase" view:
   - Add `SeamlessPayCore` framework as a dependency
   - Add `SeamlessPayCore` framework to "Link Binary" section
   - Add `SeamlessPayCore` framework to "Copy Bundle Resources" by dragging it from the left pane, Products Folder

Note: In order to make requests to our sandbox, you will need to add an API key from your dashboard.

## Demos

There are three demo apps included with the framework:

 - **[SeamlessPay iOS Demo](https://github.com/seamlesspay/ios-sdk/tree/master/SeamlessPayDemo)**: Demonstrates various capabilities of our service
 - **[Objective-C Starter](https://github.com/seamlesspay/ios-sdk/tree/master/Example_Objective-C/SeamlessPayExample)**: Reference for Objective-C integration
 - **[Swift Starter](https://github.com/seamlesspay/ios-sdk/tree/master/Example_Swift/SeamlessPayExample)**: Reference for Swift integration
