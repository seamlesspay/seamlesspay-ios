/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 ### Refactoring SingleLineCardForm Guide

 Refactoring `SingleLineCardForm` from obj-c to Swift is a large task due to the size and complexity of the file, and it will require moderate to high effort. It is recommended to refactor this file in stages to prevent issues with the remainder of your application. Here's a refactoring guide:

 **Incremental refactoring**

 To smooth the transition, you can use Swift extensions to incrementally build out the needed functionality. Here's an example:

 ```swift
 extension SingleLineCardForm {
     var swiftProperty: Type {
         get { // return appropriate value
         }
         set(value) { // set appropriate value
         }
     }

     func swiftMethod() {
         // New Swift method code
     }
 }
 ```

 Add new features or changes using Swift extensions, while keeping the existing Objective-C code operational. As you build extensions and incrementally complete the changes, you will eventually replace the original Objective-C functionalities until the entire file is in Swift. Incremental refactoring allows for much lower risks and can prevent potential issues from bringing down an entire application.

 **Improving demo application**

 To determine the acceptability of refactoring, it is necessary to enhance the functionality scope of the demo application.

 **Testing and comparing**

 This task will require testing at all stages to ensure nothing breaks during the process. Keep the Objective-C version around for reference to ensure the Swift version behaves as expected.

 **High Effort**

 - **Class and Protocol Conversions:** Convert **`SingleLineCardForm`** and its delegate protocol **`SingleLineCardForm`** to Swift. Use **`@objc`** annotation for compatibility with Objective-C code. Include delegates, methods, and instance variables.
 - **Enums:** **`SPCardBrand`** needs to be translated into Swift. Swift enums are more powerful so you could use associated values if applicable.
 - **Methods:** All methods need to be converted to Swift. Be aware of any Objective-C specific behaviors in these methods, such as Nullable and Nonnull types.

 **Low Effort**

 - **Properties:** All properties need to be translated. Swift has different property attributes, for example, instead of nullable, Swift uses optional **`?`**.
 - **UI_APPEARANCE_SELECTOR:** Swift gets a free pass by not needing the attribute associated with it, but that just means you have to [make sure your property accessor methods are compatible](https://developer.apple.com/documentation/uikit/uiappearancecontainer).
 */

#import <UIKit/UIKit.h>
#import "SPPaymentMethodCard.h"
#import "CardForm.h"

@class SingleLineCardForm;
@protocol SingleLineCardFormDelegate;

/**
 SingleLineCardForm is a text field with similar properties to UITextField,
 but specialized for collecting credit/debit card information. It manages
 multiple UITextFields under the hood to collect this information. It's
 designed to fit on a single line, and from a design perspective can be used
 anywhere a UITextField would be appropriate.
 */
IB_DESIGNABLE
@interface SingleLineCardForm : CardForm

@end

