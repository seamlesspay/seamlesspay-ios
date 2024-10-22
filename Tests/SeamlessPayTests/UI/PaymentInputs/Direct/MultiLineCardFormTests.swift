// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class MultiLineCardFormTests: XCTestCase {
  var multiLineCardForm: MultiLineCardForm!

  override func setUp() {
    super.setUp()
    multiLineCardForm = MultiLineCardForm(frame: .zero)
  }

  override func tearDown() {
    multiLineCardForm = nil
    super.tearDown()
  }

  func testInitialization() {
    XCTAssertNotNil(multiLineCardForm)
    XCTAssertNil(multiLineCardForm.delegate)
    XCTAssertNotNil(multiLineCardForm.viewModel)
    XCTAssertTrue(multiLineCardForm.isEnabled)
  }

  func testClearMethod() {
    multiLineCardForm.viewModel.cardNumber = "4111111111111111"
    multiLineCardForm.viewModel.rawExpiration = "12/25"
    multiLineCardForm.viewModel.cvc = "123"
    multiLineCardForm.viewModel.postalCode = "1234"

    multiLineCardForm.clear()

    XCTAssertEqual(multiLineCardForm.viewModel.cardNumber, .none)
    XCTAssertEqual(multiLineCardForm.viewModel.rawExpiration, .init())
    XCTAssertEqual(multiLineCardForm.viewModel.cvc, .none)
    XCTAssertEqual(multiLineCardForm.viewModel.postalCode, .none)
  }

  func testSetCountryCode() {
    multiLineCardForm.countryCode = "US"
    XCTAssertEqual(multiLineCardForm.countryCode, "US")

    multiLineCardForm.countryCode = "CA"
    XCTAssertEqual(multiLineCardForm.countryCode, "CA")
  }

  func testSetCVCDisplayConfig() {
    multiLineCardForm.setCVCDisplayConfig(.none)
    XCTAssertFalse(multiLineCardForm.viewModel.cvcDisplayed)
    XCTAssertFalse(multiLineCardForm.viewModel.cvcRequired)

    multiLineCardForm.setCVCDisplayConfig(.required)
    XCTAssertTrue(multiLineCardForm.viewModel.cvcDisplayed)
    XCTAssertTrue(multiLineCardForm.viewModel.cvcRequired)
  }

  func testSetPostalCodeDisplayConfig() {
    multiLineCardForm.setPostalCodeDisplayConfig(.none)
    XCTAssertFalse(multiLineCardForm.viewModel.postalCodeDisplayed)
    XCTAssertFalse(multiLineCardForm.viewModel.postalCodeRequired)

    multiLineCardForm.setPostalCodeDisplayConfig(.required)
    XCTAssertTrue(multiLineCardForm.viewModel.postalCodeDisplayed)
    XCTAssertTrue(multiLineCardForm.viewModel.postalCodeRequired)
  }

  func testIsEnabled() {
    multiLineCardForm.isEnabled = false
    XCTAssertFalse(multiLineCardForm.isEnabled)

    multiLineCardForm.isEnabled = true
    XCTAssertTrue(multiLineCardForm.isEnabled)
  }
}
