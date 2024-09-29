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
  func testTextFieldsOfSingleLineCardFormHaveAutocorrectionTypeNo() {
    checkSecureTextEntryCheck(
      of: SingleLineCardForm(
        config: clientConfig,
        fieldOptions: fieldOptions
      )
    )
  }

  func testTextFieldsOfMultiLineCardFormHaveAutocorrectionTypeNo() {
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

    XCTAssertEqual(
      numberField.autocorrectionType,
      .no,
      "The autocorrectionType is not No for number text field"
    )

    XCTAssertEqual(
      expirationField.autocorrectionType,
      .no,
      "The autocorrectionType is not No for expiration text field"
    )

    XCTAssertEqual(
      cvcField.autocorrectionType,
      .no,
      "The autocorrectionType is not No for cvc text field"
    )

    XCTAssertEqual(
      postalCodeField.autocorrectionType,
      .no,
      "The autocorrectionType is not No for postal code text field"
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
