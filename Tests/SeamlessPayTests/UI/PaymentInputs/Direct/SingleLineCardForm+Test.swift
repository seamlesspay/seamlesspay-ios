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
  var textField: SingleLineCardForm!

  override func setUp() {
    super.setUp()
    textField = SingleLineCardForm(
      authorization: .init(
        environment: .sandbox,
        secretKey: "test_secret_key"
      )
    )
  }

  override func tearDown() {
    textField = nil
    super.tearDown()
  }

  func testInitWithAuthorization() {
    // Then
    XCTAssertNotNil(textField.apiClient)
    XCTAssertEqual(textField.apiClient?.environment, .sandbox)
    XCTAssertEqual(textField.apiClient?.secretKey, "test_secret_key")
  }

  func testSetAuthorization() {
    // Given
    let textField = SingleLineCardForm()
    let authorization = Authorization(
      environment: .sandbox,
      secretKey: "another_test_secret_key"
    )

    // When
    textField.setAuthorization(
      authorization
    )

    // Then
    XCTAssertNotNil(textField.apiClient)
    XCTAssertEqual(textField.apiClient?.secretKey, "another_test_secret_key")
  }

  func testAPIClientAssociationKey() {
    // Given
    // When
    let textField2 = SingleLineCardForm(authorization: .init(
      environment: .production,
      secretKey: "another_test_secret_key"
    ))

    // Then
    XCTAssertNotNil(textField.apiClient)
    XCTAssertNotNil(textField2.apiClient)
    XCTAssertFalse(textField.apiClient === textField2.apiClient)
    XCTAssertNotEqual(
      textField.apiClient?.environment,
      textField2.apiClient?.environment
    )
    XCTAssertNotEqual(
      textField.apiClient?.secretKey,
      textField2.apiClient?.secretKey
    )
  }
}
