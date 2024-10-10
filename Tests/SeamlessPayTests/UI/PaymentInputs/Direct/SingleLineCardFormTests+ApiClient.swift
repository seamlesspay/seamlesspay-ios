// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayObjC
@testable import SeamlessPay

final class SingleLineCardFormTests_ApiClient: XCTestCase {
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
}
