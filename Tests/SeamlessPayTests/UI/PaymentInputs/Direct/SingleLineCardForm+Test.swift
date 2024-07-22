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
      authorization: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )
    // Then
    XCTAssertNotNil(view.apiClient)
    XCTAssertEqual(view.apiClient?.authorization.environment, .sandbox)
    XCTAssertEqual(view.apiClient?.authorization.secretKey, "test_secret_key")
  }

  func testSetAuthorization() {
    // Given
    // When
    let view = SingleLineCardForm(
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      )
    )

    // Then
    XCTAssertNotNil(view.apiClient)
    XCTAssertEqual(view.apiClient?.authorization.secretKey, "another_test_secret_key")
  }

  func testAPIClientAssociationKey() {
    // Given
    let view = SingleLineCardForm(
      authorization: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )

    // When
    let textField2 = SingleLineCardForm(
      authorization: .init(
        environment: .production,
        secretKey: "another_test_secret_key"
      )
    )

    // Then
    XCTAssertNotNil(view.apiClient)
    XCTAssertNotNil(textField2.apiClient)
    XCTAssertFalse(view.apiClient === textField2.apiClient)
    XCTAssertNotEqual(
      view.apiClient?.authorization.environment,
      textField2.apiClient?.authorization.environment
    )
    XCTAssertNotEqual(
      view.apiClient?.authorization.secretKey,
      textField2.apiClient?.authorization.secretKey
    )
  }

  func testViewModel() {
    // Given
    let view = SingleLineCardForm(
      authorization: .init(
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
      authorization: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )

    let viewModel = view.viewModel!

    // Then
    XCTAssert(viewModel.cvcRequired == false)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == false)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsRequired() {
    // Given
    // When
    let view = SingleLineCardForm(
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .required),
        postalCode: .init(display: .required)
      )
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .none),
        postalCode: .init(display: .none)
      )
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .required),
        postalCode: .init(display: .required)
      )
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(cvv: .init(display: .none), postalCode: .init(display: .none))
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel!

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
      authorization: Authorization(
        environment: .sandbox,
        secretKey: "another_test_secret_key"
      ),
      fieldOptions: .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    let viewModel = view.viewModel!

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
