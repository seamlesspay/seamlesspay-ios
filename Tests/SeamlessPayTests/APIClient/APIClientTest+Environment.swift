// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class APIClientTestEnvironment: XCTestCase {
  private var client: APIClient!

  override func setUp() {
    client = APIClient(
      authorization: .init(environment: .sandbox, secretKey: "sk_TEST"),
      session: {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [APIClientURLProtocolMock.self]
        return .init(configuration: configuration)
      }()
    )

    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }

  // MARK: - Tests
  private func testMainHostEnvironmentSet(environment: Environment, expectedBaseURL: String) {
    let expectation = XCTestExpectation(description: "Request completed")

    // given
    let client = APIClient(
      authorization: .init(environment: environment, secretKey: ""),
      session: {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [APIClientURLProtocolMock.self]
        return .init(configuration: configuration)
      }()
    )

    // when
    client.listCharges { result in

      // then
      let url = APIClientURLProtocolMock.testingRequest!.url!.absoluteString
      let startsWith = url.contains(expectedBaseURL) && url.starts(with: expectedBaseURL)
      XCTAssertTrue(startsWith)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testSandboxEnvSet() {
    testMainHostEnvironmentSet(
      environment: .sandbox,
      expectedBaseURL: "https://sandbox.seamlesspay.com"
    )
  }

  func testStagingEnvSet() {
    testMainHostEnvironmentSet(
      environment: .staging,
      expectedBaseURL: "https://api.seamlesspay.dev"
    )
  }

  func testProductionEnvSet() {
    testMainHostEnvironmentSet(
      environment: .production,
      expectedBaseURL: "https://api.seamlesspay.com"
    )
  }

  func testQatEnvSet() {
    testMainHostEnvironmentSet(
      environment: .qat,
      expectedBaseURL: "https://api.seamlesspay.io"
    )
  }
}
