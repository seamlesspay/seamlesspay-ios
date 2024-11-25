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
    multiLineCardForm = MultiLineCardForm(
      config: .init(environment: .production, secretKey: "secret_ket"),
      fieldOptions: .init(cvv: .init(display: .required), postalCode: .init(display: .required)),
      styleOptions: .default
    )
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

  func testRequiredFieldConfigurations() {
    let config = ClientConfiguration(
      environment: .production,
      secretKey: "test_secret_key",
      proxyAccountId: .none
    )
    let fieldOptions = FieldOptions(
      cvv: .init(display: .required),
      postalCode: .init(display: .required)
    )

    let multiLineCardForm = MultiLineCardForm(
      config: config,
      fieldOptions: fieldOptions
    )

    XCTAssertTrue(multiLineCardForm.viewModel.postalCodeDisplayed)
    XCTAssertTrue(multiLineCardForm.viewModel.postalCodeRequired)
    XCTAssertTrue(multiLineCardForm.viewModel.cvcDisplayed)
    XCTAssertTrue(multiLineCardForm.viewModel.cvcRequired)
  }

  func testNoneFieldConfigurations() {
    let config = ClientConfiguration(
      environment: .production,
      secretKey: "test_secret_key",
      proxyAccountId: .none
    )
    let fieldOptions = FieldOptions(
      cvv: .init(display: .none),
      postalCode: .init(display: .none)
    )

    let multiLineCardForm = MultiLineCardForm(
      config: config,
      fieldOptions: fieldOptions
    )

    XCTAssertFalse(multiLineCardForm.viewModel.postalCodeDisplayed)
    XCTAssertFalse(multiLineCardForm.viewModel.postalCodeRequired)
    XCTAssertFalse(multiLineCardForm.viewModel.cvcDisplayed)
    XCTAssertFalse(multiLineCardForm.viewModel.cvcRequired)
  }

  func testNoneOptionalConfigurations() {
    let config = ClientConfiguration(
      environment: .production,
      secretKey: "test_secret_key",
      proxyAccountId: .none
    )
    let fieldOptions = FieldOptions(
      cvv: .init(display: .optional),
      postalCode: .init(display: .optional)
    )

    let multiLineCardForm = MultiLineCardForm(
      config: config,
      fieldOptions: fieldOptions
    )

    XCTAssertTrue(multiLineCardForm.viewModel.postalCodeDisplayed)
    XCTAssertFalse(multiLineCardForm.viewModel.postalCodeRequired)
    XCTAssertTrue(multiLineCardForm.viewModel.cvcDisplayed)
    XCTAssertFalse(multiLineCardForm.viewModel.cvcRequired)
  }

  func testIsEnabled() {
    multiLineCardForm.isEnabled = false
    XCTAssertFalse(multiLineCardForm.isEnabled)

    multiLineCardForm.isEnabled = true
    XCTAssertTrue(multiLineCardForm.isEnabled)
  }

  func testInitializerWithDefaultStyleOptions() {
    let config = ClientConfiguration(
      environment: .production,
      secretKey: "test_secret_key",
      proxyAccountId: .none
    )

    let multiLineCardForm = MultiLineCardForm(config: config)

    XCTAssertNotNil(multiLineCardForm)
    XCTAssertEqual(multiLineCardForm.styleOptions, .default)
  }

  func testInitializerWithCustomStyleOptions() {
    let config = ClientConfiguration(
      environment: .production,
      secretKey: "test_secret_key",
      proxyAccountId: .none
    )

    let styleOptions = StyleOptions(
      colors: .init(
        light: .init(theme: .init(neutral: .blue, primary: .green, danger: .red)),
        dark: .init(theme: .init(neutral: .purple, primary: .yellow, danger: .cyan))
      ),
      shapes: .init(cornerRadius: 8),
      typography: .init(font: .boldSystemFont(ofSize: 18), scale: 1.2),
      iconSet: .none
    )

    let multiLineCardForm = MultiLineCardForm(
      config: config,
      styleOptions: styleOptions
    )

    XCTAssertNotNil(multiLineCardForm)
    XCTAssertNotEqual(multiLineCardForm.styleOptions, .default)
  }
}
