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

  // MARK: On Submit Validation
  func testFormValidationForField_NumberValid() {
    viewModel.cardNumber = "4242424242424242"
    XCTAssertNil(viewModel.formValidationForField(.number))
  }

  func testFormValidationForField_NumberInvalid() {
    viewModel.cardNumber = "1234"
    let output = viewModel.formValidationForField(.number)
    switch output {
    case .numberInvalid:
      break
    default:
      XCTFail("Expected .numberInvalid, got \(output?.localizedDescription ?? "none")")
    }
  }

  func testFormValidationForField_NumberRequired() {
    viewModel.cardNumber = ""
    let output = viewModel.formValidationForField(.number)
    switch output {
    case .numberRequired:
      break
    default:
      XCTFail("Expected .numberRequired, got \(output?.localizedDescription ?? "none")")
    }
  }

  func testFormValidationForField_ExpirationValid() {
    viewModel.rawExpiration = "12/99"
    XCTAssertNil(viewModel.formValidationForField(.expiration))
  }

  func testFormValidationForField_ExpirationInvalidDate() {
    viewModel.rawExpiration = "13/99"
    let output = viewModel.formValidationForField(.expiration)
    switch output {
    case .expirationInvalidDate:
      break
    default:
      XCTFail(
        "Expected .expirationInvalidDate, got \(output?.localizedDescription ?? "none")"
      )
    }
  }

  func testFormValidationForField_ExpirationInvalid() {
    viewModel.rawExpiration = "12/9"
    let output = viewModel.formValidationForField(.expiration)
    switch output {
    case .expirationInvalid:
      break
    default:
      XCTFail(
        "Expected .expirationInvalid, got \(output?.localizedDescription ?? "none")"
      )
    }
  }

  func testFormValidationForField_ExpirationRequired() {
    viewModel.rawExpiration = ""
    let output = viewModel.formValidationForField(.expiration)
    switch output {
    case .expirationRequired:
      break
    default:
      XCTFail(
        "Expected .expirationRequired, got \(output?.localizedDescription ?? "none")"
      )
    }
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
    switch output {
    case .cvcInvalid:
      break
    default:
      XCTFail("Expected .cvcInvalid, got \(output?.localizedDescription ?? "none")")
    }
  }

  func testFormValidationForField_CVCRequired() {
    viewModel.cvc = ""
    viewModel.cvcDisplayConfig = .required
    let output = viewModel.formValidationForField(.CVC)
    switch output {
    case .cvcRequired:
      break
    default:
      XCTFail("Expected .cvcRequired, got \(output?.localizedDescription ?? "none")")
    }
  }

  func testFormValidationForField_PostalCodeValid() {
    viewModel.postalCode = "12345"
    viewModel.postalCodeDisplayConfig = .required
    let output = viewModel.formValidationForField(.postalCode)
    switch output {
    case .none:
      break
    default:
      XCTFail("Expected .none, got \(output?.localizedDescription ?? "none")")
    }
  }

  func testFormValidationForField_PostalCodeRequired() {
    viewModel.postalCode = ""
    viewModel.postalCodeDisplayConfig = .required
    let output = viewModel.formValidationForField(.postalCode)
    switch output {
    case .postalCodeRequired:
      break
    default:
      XCTFail(
        "Expected .postalCodeRequired, got \(output?.localizedDescription ?? "none")"
      )
    }
  }
}
