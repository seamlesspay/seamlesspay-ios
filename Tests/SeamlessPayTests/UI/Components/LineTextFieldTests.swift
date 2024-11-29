// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class LineTextFieldTests: XCTestCase {
  var lineTextField: LineTextField!

  override func setUp() {
    super.setUp()
    lineTextField = LineTextField(frame: .zero)
  }

  override func tearDown() {
    lineTextField = nil
    super.tearDown()
  }

  func testFloatingPlaceholder() {
    // Test setting floating placeholder
    let placeholder = "Test Placeholder"
    lineTextField.floatingPlaceholder = placeholder
    XCTAssertEqual(lineTextField.floatingPlaceholderLabel.text, placeholder)
  }

  func testErrorMessage() {
    // Test setting error message
    let errorMessage = "Test Error"
    lineTextField.errorMessage = errorMessage
    XCTAssertEqual(lineTextField.errorLabel.text, errorMessage)
  }

  func testSetupTextField() {
    XCTAssertEqual(lineTextField.textAlignment, .left)
    XCTAssertEqual(lineTextField.borderStyle, .none)
    XCTAssertEqual(lineTextField.clearButtonMode, .never)
  }

  func testSetupFloatingPlaceholder() {
    XCTAssertEqual(lineTextField.floatingPlaceholderLabel.numberOfLines, 1)
  }

  func testSetupErrorLabel() {
    XCTAssertEqual(lineTextField.errorLabel.numberOfLines, 0)
  }

  // The `validText' property of the LineTextField should ignore any error message values.
  func testErrorMessageUpdatesValidText() {
    lineTextField.errorMessage = "Test Error"
    XCTAssertFalse(lineTextField.validText)

    lineTextField.errorMessage = ""
    XCTAssertFalse(lineTextField.validText)

    lineTextField.errorMessage = .none
    XCTAssertFalse(lineTextField.validText)
  }
}
