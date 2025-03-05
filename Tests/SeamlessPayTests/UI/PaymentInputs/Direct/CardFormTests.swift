// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class CardFormTests: XCTestCase {
  var cardForm: CardForm!

  override func setUp() {
    super.setUp()
    cardForm = CardForm(
      config: .init(environment: .production, secretKey: "secret_ket"),
      fieldOptions: .init(cvv: .init(display: .required), postalCode: .init(display: .required)),
      styleOptions: .default
    )
  }

  override func tearDown() {
    cardForm = nil
    super.tearDown()
  }

  func testInitialization() {
    XCTAssertNotNil(cardForm)
    XCTAssertNil(cardForm.delegate)
    XCTAssertNotNil(cardForm.viewModel)
    XCTAssertTrue(cardForm.isEnabled)
  }

  func testClearMethod() {
    cardForm.viewModel.cardNumber = "4111111111111111"
    cardForm.viewModel.rawExpiration = "12/25"
    cardForm.viewModel.cvc = "123"
    cardForm.viewModel.postalCode = "1234"

    cardForm.clear()

    XCTAssertEqual(cardForm.viewModel.cardNumber, .none)
    XCTAssertEqual(cardForm.viewModel.rawExpiration, .init())
    XCTAssertEqual(cardForm.viewModel.cvc, .none)
    XCTAssertEqual(cardForm.viewModel.postalCode, .none)
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

    let cardForm = CardForm(
      config: config,
      fieldOptions: fieldOptions
    )

    XCTAssertTrue(cardForm.viewModel.postalCodeDisplayed)
    XCTAssertTrue(cardForm.viewModel.postalCodeRequired)
    XCTAssertTrue(cardForm.viewModel.cvcDisplayed)
    XCTAssertTrue(cardForm.viewModel.cvcRequired)
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

    let cardForm = CardForm(
      config: config,
      fieldOptions: fieldOptions
    )

    XCTAssertFalse(cardForm.viewModel.postalCodeDisplayed)
    XCTAssertFalse(cardForm.viewModel.postalCodeRequired)
    XCTAssertFalse(cardForm.viewModel.cvcDisplayed)
    XCTAssertFalse(cardForm.viewModel.cvcRequired)
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

    let cardForm = CardForm(
      config: config,
      fieldOptions: fieldOptions
    )

    XCTAssertTrue(cardForm.viewModel.postalCodeDisplayed)
    XCTAssertFalse(cardForm.viewModel.postalCodeRequired)
    XCTAssertTrue(cardForm.viewModel.cvcDisplayed)
    XCTAssertFalse(cardForm.viewModel.cvcRequired)
  }

  func testIsEnabled() {
    cardForm.isEnabled = false
    XCTAssertFalse(cardForm.isEnabled)

    cardForm.isEnabled = true
    XCTAssertTrue(cardForm.isEnabled)
  }

  func testInitializerWithDefaultStyleOptions() {
    let config = ClientConfiguration(
      environment: .production,
      secretKey: "test_secret_key",
      proxyAccountId: .none
    )

    let cardForm = CardForm(config: config)

    XCTAssertNotNil(cardForm)
    XCTAssertEqual(cardForm.styleOptions, .default)
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

    let cardForm = CardForm(
      config: config,
      styleOptions: styleOptions
    )

    XCTAssertNotNil(cardForm)
    XCTAssertNotEqual(cardForm.styleOptions, .default)
  }
}
