// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class APIClientRefundTest: XCTestCase {
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

  // MARK: Tests
  func testCreateRefundRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.createRefund(
      token: "test_token",
      amount: "101"
    ) { result in

      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertEqual(url, "https://sandbox.seamlesspay.com/refunds")
      XCTAssertEqual(method, "POST")

      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2020")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")

      let token = body["token"] as! String
      let amount = body["amount"] as! String

      // parameters
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(amount, "101")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }
}
