// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class APIClientTestEnvironment: XCTestCase {
  private var client: APIClient!

  override func setUp() {
    client = APIClient(
      session: .init(
        configuration: {
          let configuration = URLSessionConfiguration.default
          configuration.protocolClasses = [APIClientURLProtocolMock.self]
          return configuration
        }()
      )
    )

    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }

  // MARK: - Tests

  private func testMainHostEnvironmentSet(_ environment: Environment, expectedBaseURL: String) {
    let expectation = XCTestExpectation(description: "Request completed")

    // given
    client.set(secretKey: "", publishableKey: "", environment: environment)

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
    testMainHostEnvironmentSet(.sandbox, expectedBaseURL: "https://sandbox.seamlesspay.com")
  }

  func testStagingEnvSet() {
    testMainHostEnvironmentSet(.staging, expectedBaseURL: "https://api.seamlesspay.dev")
  }

  func testProductionEnvSet() {
    testMainHostEnvironmentSet(.production, expectedBaseURL: "https://api.seamlesspay.com")
  }

  func testQatEnvSet() {
    testMainHostEnvironmentSet(.qat, expectedBaseURL: "https://api.seamlesspay.io")
  }
}
