// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class CardFormTests: XCTestCase {
  let clientConfig = ClientConfiguration(environment: .production, secretKey: "")
  let fieldOptions = FieldOptions(
    cvv: .init(display: .required),
    postalCode: .init(display: .required)
  )
  func testTextFieldsOfSingleLineCardFormHaveSecureTextEntryEnabled() {
    checkSecureTextEntryCheck(
      of: SingleLineCardForm(
        config: clientConfig,
        fieldOptions: fieldOptions
      )
    )
  }

  func testTextFieldsOfMultiLineCardFormHaveSecureTextEntryEnabled() {
    checkSecureTextEntryCheck(
      of: MultiLineCardForm(
        config: clientConfig,
        fieldOptions: fieldOptions
      )
    )
  }

  private func checkSecureTextEntryCheck(of cardForm: CardForm) {
    let numberField: SPFormTextField = cardForm.getInstanceVariable("_numberField")!
    let expirationField: SPFormTextField = cardForm.getInstanceVariable("_expirationField")!
    let cvcField: SPFormTextField = cardForm.getInstanceVariable("_cvcField")!
    let postalCodeField: SPFormTextField = cardForm.getInstanceVariable("_postalCodeField")!

    XCTAssertTrue(
      numberField.isSecureTextEntry,
      "The secureTextEntry option is not activated for number text field"
    )
    XCTAssertTrue(
      expirationField.isSecureTextEntry,
      "The secureTextEntry option is not activated for expiration date text field"
    )
    XCTAssertTrue(
      cvcField.isSecureTextEntry,
      "The secureTextEntry option is not activated for the cvc text field"
    )
    XCTAssertTrue(
      postalCodeField.isSecureTextEntry,
      "The secureTextEntry option is not activated for the postal code text field"
    )
  }
}

// MARK: Get Instance Variable
private extension CardForm {
  func getInstanceVariable<T>(_ propertyName: String) -> T? {
    class_getInstanceVariable(
      type(of: self),
      propertyName
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? T
    }
  }
}
