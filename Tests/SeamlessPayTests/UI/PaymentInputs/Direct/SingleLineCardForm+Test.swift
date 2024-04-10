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
  var view: SingleLineCardForm!

  override func setUp() {
    super.setUp()
    view = SingleLineCardForm(
      authorization: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )
  }

  override func tearDown() {
    view = nil
    super.tearDown()
  }

  func testInitWithAuthorization() {
    // Then
    XCTAssertNotNil(view.apiClient)
    XCTAssertEqual(view.apiClient?.environment, .sandbox)
    XCTAssertEqual(view.apiClient?.secretKey, "test_secret_key")
  }

  func testSetAuthorization() {
    // Given
    let view = SingleLineCardForm()
    let authorization = Authorization(
      environment: .sandbox,
      secretKey: "another_test_secret_key"
    )

    // When
    view.setAuthorization(
      authorization
    )

    // Then
    XCTAssertNotNil(view.apiClient)
    XCTAssertEqual(view.apiClient?.secretKey, "another_test_secret_key")
  }

  func testAPIClientAssociationKey() {
    // Given
    // When
    let textField2 = SingleLineCardForm(authorization: .init(
      environment: .production,
      secretKey: "another_test_secret_key"
    ))

    // Then
    XCTAssertNotNil(view.apiClient)
    XCTAssertNotNil(textField2.apiClient)
    XCTAssertFalse(view.apiClient === textField2.apiClient)
    XCTAssertNotEqual(
      view.apiClient?.environment,
      textField2.apiClient?.environment
    )
    XCTAssertNotEqual(
      view.apiClient?.secretKey,
      textField2.apiClient?.secretKey
    )
  }

  func testViewModel() {
    // Then
    XCTAssertNotNil(view.viewModel)
  }

  func testViewModelDefaultInitialization() {
    // Given
    // When
    let viewModel = view.viewModel!

    // Then
    XCTAssert(viewModel.cvcRequired == false)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == false)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsRequired() {
    // Given
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(
      .init(
        cvv: .init(display: .required),
        postalCode: .init(display: .required)
      )
    )

    // Then
    XCTAssert(viewModel.cvcRequired == true)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == true)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsOptional() {
    // Given
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(
      .init(
        cvv: .init(display: .optional),
        postalCode: .init(display: .optional)
      )
    )

    // Then
    XCTAssert(viewModel.cvcRequired == false)
    XCTAssert(viewModel.cvcDisplayed == true)
    XCTAssert(viewModel.postalCodeRequired == false)
    XCTAssert(viewModel.postalCodeDisplayed == true)
  }

  func testSetFieldOptionsNone() {
    // Given
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(
      .init(
        cvv: .init(display: .none),
        postalCode: .init(display: .none)
      )
    )

    // Then
    XCTAssert(viewModel.cvcRequired == false)
    XCTAssert(viewModel.cvcDisplayed == false)
    XCTAssert(viewModel.postalCodeRequired == false)
    XCTAssert(viewModel.postalCodeDisplayed == false)
  }

  func testIsValidStateCVCAndPostalRequired() {
    // Given
    let view = SingleLineCardForm()
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(.init(
      cvv: .init(display: .required),
      postalCode: .init(display: .required)
    ))
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
    let view = SingleLineCardForm()
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(.init(cvv: .init(display: .none), postalCode: .init(display: .none)))
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
    let view = SingleLineCardForm()
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(.init(
      cvv: .init(display: .optional),
      postalCode: .init(display: .optional)
    ))
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
    let view = SingleLineCardForm()
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(.init(
      cvv: .init(display: .optional),
      postalCode: .init(display: .optional)
    ))
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
    let view = SingleLineCardForm()
    let viewModel = view.viewModel!

    // When
    view.setFieldOptions(.init(
      cvv: .init(display: .optional),
      postalCode: .init(display: .optional)
    ))
    viewModel.cardNumber = "4242424242424242"

    // Then
    XCTAssertFalse(view.isValid)

    // When
    viewModel.rawExpiration = "11/99"

    // Then
    XCTAssertTrue(view.isValid)
  }
}
