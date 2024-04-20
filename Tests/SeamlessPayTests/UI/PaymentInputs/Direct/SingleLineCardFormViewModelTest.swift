// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayObjC
@testable import SeamlessPay

final class CardFormViewModelTest: XCTestCase {
  var viewModel: CardFormViewModel!

  override func setUp() {
    super.setUp()

    viewModel = CardFormViewModel()
  }

  override func tearDown() {
    viewModel = nil
    super.tearDown()
  }

  func testViewModelDefaultsValidation() {
    // Given
    // When

    // Then
    XCTAssertEqual(viewModel.cvc, .none)
    XCTAssertFalse(viewModel.isFieldValid(.CVC))

    XCTAssertEqual(viewModel.rawExpiration, .init())
    XCTAssertFalse(viewModel.isFieldValid(.expiration))

    XCTAssertEqual(viewModel.cardNumber, .none)
    XCTAssertFalse(viewModel.isFieldValid(.number))

    XCTAssertEqual(viewModel.postalCode, .none)
    XCTAssertFalse(viewModel.isFieldValid(.postalCode))
  }

  func testViewModelValidationWithValidValues() {
    // Given
    // When

    // Then
    viewModel.cvc = "112"
    XCTAssertEqual(viewModel.cvc, "112")
    XCTAssertTrue(viewModel.isFieldValid(.CVC))
    XCTAssertEqual(viewModel.validationState(for: .CVC), .valid)

    viewModel.rawExpiration = "11/99"
    XCTAssertEqual(viewModel.rawExpiration, "11/99")
    XCTAssertEqual(viewModel.expirationMonth, "11")
    XCTAssertEqual(viewModel.expirationYear, "99")
    XCTAssertTrue(viewModel.isFieldValid(.expiration))
    XCTAssertEqual(viewModel.validationState(for: .expiration), .valid)

    viewModel.cardNumber = "4242424242424242"
    XCTAssertEqual(viewModel.cardNumber, "4242424242424242")
    XCTAssertTrue(viewModel.isFieldValid(.number))
    XCTAssertEqual(viewModel.validationState(for: .number), .valid)

    viewModel.postalCode = "10001"
    XCTAssertEqual(viewModel.postalCode, "10001")
    XCTAssertTrue(viewModel.isFieldValid(.postalCode))
    XCTAssertEqual(viewModel.validationState(for: .postalCode), .valid)
  }

  func testViewModelValidationWithInvalidValues() {
    // Given
    // When

    // Then
    viewModel.cvc = "9"
    XCTAssertEqual(viewModel.cvc, "9")
    XCTAssertFalse(viewModel.isFieldValid(.CVC))
    XCTAssertEqual(viewModel.validationState(for: .CVC), .incomplete)

    viewModel.rawExpiration = "09/08"
    XCTAssertEqual(viewModel.rawExpiration, "09/08")
    XCTAssertEqual(viewModel.expirationMonth, "09")
    XCTAssertEqual(viewModel.expirationYear, "08")
    XCTAssertFalse(viewModel.isFieldValid(.expiration))
    XCTAssertEqual(viewModel.validationState(for: .expiration), .invalid)

    viewModel.cardNumber = "123"
    XCTAssertEqual(viewModel.cardNumber, "123")
    XCTAssertFalse(viewModel.isFieldValid(.number))
    XCTAssertEqual(viewModel.validationState(for: .number), .invalid)

    viewModel.postalCode = ""
    XCTAssertEqual(viewModel.postalCode, "")
    XCTAssertFalse(viewModel.isFieldValid(.postalCode))
    XCTAssertEqual(viewModel.validationState(for: .postalCode), .incomplete)
  }
}
