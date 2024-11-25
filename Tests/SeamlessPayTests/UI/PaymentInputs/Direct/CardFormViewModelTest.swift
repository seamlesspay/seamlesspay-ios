// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayObjC
@testable import SeamlessPay

// MARK: Tests
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

  // MARK: - Display Config
  func testCvcDisplayConfigNone() {
    viewModel.cvcDisplayConfig = .none
    XCTAssertEqual(
      viewModel.cvcDisplayConfig,
      .none
    )

    XCTAssertFalse(viewModel.cvcDisplayed)
    XCTAssertFalse(viewModel.cvcRequired)
  }

  func testCvcDisplayConfigRequired() {
    viewModel.cvcDisplayConfig = .required
    XCTAssertEqual(
      viewModel.cvcDisplayConfig,
      .required
    )

    XCTAssertTrue(viewModel.cvcDisplayed)
    XCTAssertTrue(viewModel.cvcRequired)
  }

  func testCvcDisplayConfigOptional() {
    viewModel.cvcDisplayConfig = .optional
    XCTAssertEqual(
      viewModel.cvcDisplayConfig,
      .optional
    )

    XCTAssertTrue(viewModel.cvcDisplayed)
    XCTAssertFalse(viewModel.cvcRequired)
  }

  func testPostalCodeDisplayConfigNone() {
    viewModel.postalCodeDisplayConfig = .none
    XCTAssertEqual(
      viewModel.postalCodeDisplayConfig,
      .none
    )

    XCTAssertFalse(viewModel.postalCodeDisplayed)
    XCTAssertFalse(viewModel.postalCodeRequired)
  }

  func testPostalCodeDisplayConfigRequired() {
    viewModel.postalCodeDisplayConfig = .required
    XCTAssertEqual(
      viewModel.postalCodeDisplayConfig,
      .required
    )

    XCTAssertTrue(viewModel.postalCodeDisplayed)
    XCTAssertTrue(viewModel.postalCodeRequired)
  }

  func testPostalCodeDisplayConfigOptional() {
    viewModel.postalCodeDisplayConfig = .optional
    XCTAssertEqual(
      viewModel.postalCodeDisplayConfig,
      .optional
    )

    XCTAssertTrue(viewModel.postalCodeDisplayed)
    XCTAssertFalse(viewModel.postalCodeRequired)
  }

  // MARK: isValid
  func testIsValidWithValidData() {
    viewModel.cardNumber = "4242424242424242" // Valid Visa card number
    viewModel.rawExpiration = "12/99"
    viewModel.cvc = "123"
    viewModel.postalCode = "12345"
    viewModel.cvcDisplayConfig = .required
    viewModel.postalCodeDisplayConfig = .required

    XCTAssertTrue(viewModel.isValid, "The card form should be valid with correct data.")
  }

  func testIsValidWithInvalidCardNumber() {
    viewModel.cardNumber = "1234567890123456" // Invalid card number
    viewModel.rawExpiration = "12/99"
    viewModel.cvc = "123"
    viewModel.postalCode = "12345"
    viewModel.cvcDisplayConfig = .required
    viewModel.postalCodeDisplayConfig = .required

    XCTAssertFalse(
      viewModel.isValid,
      "The card form should be invalid with incorrect card number."
    )
  }

  func testIsValidWithInvalidExpirationDate() {
    viewModel.cardNumber = "4242424242424242" // Valid Visa card number
    viewModel.rawExpiration = "22/99" // Invalid month
    viewModel.cvc = "123"
    viewModel.postalCode = "12345"
    viewModel.cvcDisplayConfig = .required
    viewModel.postalCodeDisplayConfig = .required

    XCTAssertFalse(
      viewModel.isValid,
      "The card form should be invalid with incorrect expiration date."
    )
  }

  func testIsValidWithInvalidCVC() {
    viewModel.cardNumber = "4242424242424242" // Valid Visa card number
    viewModel.rawExpiration = "12/99"
    viewModel.cvc = "12" // Invalid CVC
    viewModel.postalCode = "12345"
    viewModel.cvcDisplayConfig = .required
    viewModel.postalCodeDisplayConfig = .required

    XCTAssertFalse(viewModel.isValid, "The card form should be invalid with incorrect CVC.")
  }

  func testIsValidWithInvalidPostalCode() {
    viewModel.cardNumber = "4242424242424242" // Valid Visa card number
    viewModel.rawExpiration = "12/99"
    viewModel.cvc = "123"
    viewModel.postalCode = "" // Invalid postal code
    viewModel.cvcDisplayConfig = .required
    viewModel.postalCodeDisplayConfig = .required

    XCTAssertFalse(
      viewModel.isValid,
      "The card form should be invalid with incorrect postal code."
    )
  }

  func testIsValidWithOptionalCVC() {
    viewModel.cardNumber = "4242424242424242" // Valid Visa card number
    viewModel.rawExpiration = "12/99"
    viewModel.cvc = "" // CVC is optional
    viewModel.postalCode = "12345"
    viewModel.cvcDisplayConfig = .optional // CVC is optional
    viewModel.postalCodeDisplayConfig = .required

    XCTAssertTrue(viewModel.isValid, "The card form should be valid with optional CVC.")
  }

  func testIsValidWithOptionalPostalCode() {
    viewModel.cardNumber = "4242424242424242" // Valid Visa card number
    viewModel.rawExpiration = "12/99"
    viewModel.postalCode = "" // Postal code is optional
    viewModel.cvc = "123"
    viewModel.cvcDisplayConfig = .required
    viewModel.postalCodeDisplayConfig = .optional // Postal code is optional

    XCTAssertTrue(
      viewModel.isValid,
      "The card form should be valid with optional postal code."
    )
  }
}

// MARK: Form Validation
extension CardFormViewModelTest {
  func testFormValidationForField_NumberValid() {
    viewModel.cardNumber = "4242424242424242"
    XCTAssertNil(viewModel.formValidationForField(.number))
  }

  func testFormValidationForField_NumberInvalid() {
    viewModel.cardNumber = "1234"
    let output = viewModel.formValidationForField(.number)
    XCTAssertEqual(
      output,
      .numberInvalid,
      "Expected .numberInvalid error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_NumberRequired() {
    viewModel.cardNumber = ""
    let output = viewModel.formValidationForField(.number)
    XCTAssertEqual(
      output,
      .numberRequired,
      "Expected .numberRequired error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_ExpirationValid() {
    viewModel.rawExpiration = "12/99"
    XCTAssertNil(viewModel.formValidationForField(.expiration))
  }

  func testFormValidationForField_ExpirationInvalidDate() {
    viewModel.rawExpiration = "13/99"
    let output = viewModel.formValidationForField(.expiration)
    XCTAssertEqual(
      output,
      .expirationInvalidDate,
      "Expected .expirationInvalidDate error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_ExpirationInvalid() {
    viewModel.rawExpiration = "12/9"
    let output = viewModel.formValidationForField(.expiration)
    XCTAssertEqual(
      output,
      .expirationInvalid,
      "Expected .expirationInvalid error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_ExpirationRequired() {
    viewModel.rawExpiration = ""
    let output = viewModel.formValidationForField(.expiration)
    XCTAssertEqual(
      output,
      .expirationRequired,
      "Expected .expirationRequired error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_CVCValid() {
    viewModel.cvc = "123"
    viewModel.cvcDisplayConfig = .required
    XCTAssertNil(viewModel.formValidationForField(.CVC))
  }

  func testFormValidationForField_CVCInvalid() {
    viewModel.cvc = "12"
    viewModel.cvcDisplayConfig = .required
    let output = viewModel.formValidationForField(.CVC)
    XCTAssertEqual(
      output,
      .cvcInvalid,
      "Expected .cvcInvalid error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_CVCRequired() {
    viewModel.cvc = ""
    viewModel.cvcDisplayConfig = .required
    let output = viewModel.formValidationForField(.CVC)
    XCTAssertEqual(
      output,
      .cvcRequired,
      "Expected .cvcRequired error, got - \(output?.localizedDescription ?? "none")"
    )
  }

  func testFormValidationForField_PostalCodeValid() {
    viewModel.postalCode = "12345"
    viewModel.postalCodeDisplayConfig = .required
    let output = viewModel.formValidationForField(.postalCode)
    XCTAssertNil(output, "Expected nil error, got - \(output?.localizedDescription ?? "none")")
  }

  func testFormValidationForField_PostalCodeRequired() {
    viewModel.postalCode = ""
    viewModel.postalCodeDisplayConfig = .required
    let output = viewModel.formValidationForField(.postalCode)
    XCTAssertEqual(
      output,
      .postalCodeRequired,
      "Expected .postalCodeRequired error, got - \(output?.localizedDescription ?? "none")"
    )
  }
}

// MARK: Real-time Validation
extension CardFormViewModelTest {
  func testRealTimeValidationForField_NumberRequired() {
    viewModel.cardNumber = ""
    XCTAssertNil(
      viewModel.realTimeValidationForField(.number, isFocused: false),
      "Expected nil real-time validation error for empty card number"
    )
  }

  func testRealTimeValidationForField_NumberInvalid() {
    viewModel.cardNumber = "1234"
    XCTAssertEqual(
      viewModel.realTimeValidationForField(.number, isFocused: true),
      .numberInvalid,
      "Expected numberInvalid real-time validation error for invalid card number"
    )
  }

  func testRealTimeValidationForField_ExpirationRequired() {
    viewModel.rawExpiration = ""
    XCTAssertNil(
      viewModel.realTimeValidationForField(.expiration, isFocused: false),
      "Expected nil real-time validation error for empty expiration date"
    )
  }

  func testRealTimeValidationForField_ExpirationInvalid() {
    viewModel.rawExpiration = "13/25"
    XCTAssertEqual(
      viewModel.realTimeValidationForField(.expiration, isFocused: true),
      .expirationInvalidDate,
      "Expected expirationInvalidDate real-time validation error for invalid expiration date"
    )
  }

  func testRealTimeValidationForField_CVCRequired() {
    viewModel.cvcDisplayConfig = .required
    viewModel.cvc = ""
    XCTAssertNil(
      viewModel.realTimeValidationForField(.CVC, isFocused: false),
      "Expected nil real-time validation error for empty CVC"
    )
  }

  func testRealTimeValidationForField_CVCInvalid() {
    viewModel.cvcDisplayConfig = .required
    viewModel.cvc = "12"
    XCTAssertNil(
      viewModel.realTimeValidationForField(.CVC, isFocused: true),
      "Expected nil real-time validation error for invalid CVC"
    )
  }

  func testRealTimeValidationForField_PostalCodeRequired() {
    viewModel.postalCodeDisplayConfig = .required
    viewModel.postalCode = ""
    XCTAssertNil(
      viewModel.realTimeValidationForField(.postalCode, isFocused: false),
      "Expected nil real-time validation error for empty postal code"
    )
  }

  func testRealTimeValidationForField_PostalCodeInvalid() {
    viewModel.postalCodeDisplayConfig = .required
    viewModel.postalCode = "123"
    XCTAssertNil(
      viewModel.realTimeValidationForField(.postalCode, isFocused: true),
      "Expected nil real-time validation error for invalid postal code"
    )
  }
}
