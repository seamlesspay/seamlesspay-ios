// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayObjC
@testable import SeamlessPay

final class SingleLineCardFormTest: XCTestCase {
  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testInitWithAuthorization() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )
    // Then
    XCTAssertNotNil(view.viewModel.apiClient)
    XCTAssertEqual(view.viewModel.apiClient?.config.environment, .sandbox)
    XCTAssertEqual(view.viewModel.apiClient?.config.secretKey, "test_secret_key")
  }

  func testSetAuthorization() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      )
    )

    // Then
    XCTAssertNotNil(view.viewModel.apiClient)
    XCTAssertEqual(view.viewModel.apiClient?.config.secretKey, "another_test_secret_key")
  }

  func testAPIClientAssociationKey() {
    // Given
    let view = SingleLineCardForm(
      config: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )

    // When
    let textField2 = SingleLineCardForm(
      config: .init(
        environment: .production,
        secretKey: "another_test_secret_key"
      )
    )

    // Then
    XCTAssertNotNil(view.viewModel.apiClient)
    XCTAssertNotNil(textField2.viewModel.apiClient)
    XCTAssertFalse(view.viewModel.apiClient === textField2.viewModel.apiClient)
    XCTAssertNotEqual(
      view.viewModel.apiClient?.config.environment,
      textField2.viewModel.apiClient?.config.environment
    )
    XCTAssertNotEqual(
      view.viewModel.apiClient?.config.secretKey,
      textField2.viewModel.apiClient?.config.secretKey
    )
  }

  func testViewModel() {
    // Given
    let view = SingleLineCardForm(
      config: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )
    // Then
    XCTAssertNotNil(view.viewModel)
  }

  func testViewModelDefaultInitialization() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )

    let viewModel = view.viewModel

    // Then
    XCTAssert(viewModel.cvcRequired == true)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == true)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsRequired() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .required),
        postalCode: .init(display: .required)
      )
    )

    let viewModel = view.viewModel

    // Then
    XCTAssert(viewModel.cvcRequired == true)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == true)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsOptional() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel

    // Then
    XCTAssert(viewModel.cvcRequired == false)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == false)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsNone() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .none),
        postalCode: .init(display: .none)
      )
    )

    let viewModel = view.viewModel

    // Then
    XCTAssert(viewModel.cvcRequired == false)
    XCTAssert(viewModel.cvcDisplayed == false)
    XCTAssert(viewModel.postalCodeRequired == false)
    XCTAssert(viewModel.postalCodeDisplayed == false)
  }

  func testIsValidStateCVCAndPostalRequired() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .required),
        postalCode: .init(display: .required)
      )
    )

    let viewModel = view.viewModel

    // When
    viewModel.cardNumber = "4242424242424242"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.rawExpiration = "11/99"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.cvc = "123"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.postalCode = "10001"

    // Then
    XCTAssertTrue(view.isValid)
  }

  func testIsValidStateCVCAndPostalNone() {
    // Given
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(cvv: .init(display: .none), postalCode: .init(display: .none))
    )

    let viewModel = view.viewModel

    // When
    viewModel.cardNumber = "4242424242424242"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.rawExpiration = "11/99"

    // Then
    XCTAssertTrue(view.isValid)
  }

  func testIsValidStateCVCAndPostalOptionalNoPostal() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel

    viewModel.cardNumber = "4242424242424242"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.rawExpiration = "11/99"

    // Then
    XCTAssertTrue(view.isValid)

    // When
    viewModel.cvc = "123"

    // Then
    XCTAssertTrue(view.isValid)
  }

  func testIsValidStateCVCAndPostalOptionalNoCVC() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel

    viewModel.cardNumber = "4242424242424242"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.rawExpiration = "11/99"

    // Then
    XCTAssertTrue(view.isValid)

    // When
    viewModel.postalCode = "10001"

    // Then
    XCTAssertTrue(view.isValid)
  }

  func testIsValidStateCVCAndPostalOptionalAndAbsent() {
    // Given
    // When
    let view = SingleLineCardForm(
      config: ClientConfiguration(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel

    // When
    viewModel.cardNumber = "4242424242424242"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.rawExpiration = "11/99"

    // Then
    XCTAssertTrue(view.isValid)
  }
}
