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

  private func checkSecureTextEntryCheck(of cardForm: UIView) {
    let textFields = cardForm.allTextFields()

    XCTAssertFalse(
      textFields.isEmpty,
      "No text fields found in the card form - \(cardForm.debugDescription)"
    )

    textFields.forEach { textField in
      XCTAssertEqual(
        textField.autocorrectionType,
        .no,
        "The autocorrectionType is not No for text field \(textField.debugDescription)"
      )
    }
  }
}

private extension UIView {
  func allTextFields() -> [UITextField] {
    var textFields = [UITextField]()

    if let textField = self as? UITextField {
      textFields.append(textField)
    }

    for subview in subviews {
      textFields.append(contentsOf: subview.allTextFields())
    }

    return textFields
  }
}
