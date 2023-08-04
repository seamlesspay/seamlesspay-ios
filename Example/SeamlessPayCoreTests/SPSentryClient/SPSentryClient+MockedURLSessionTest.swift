// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class SPSentryClientWithMockedURLSessionTest: XCTestCase {
  private var client: SPSentryClient!

  override func setUp() {
    client = SPSentryClient(
      dsn: "https://test.secretkey@test.host/test.projectid",
      config: .init(
        userId: "test.valid.userid",
        environment: "test.valid.environment"
      ),
      session: .init(
        configuration: {
          let configuration = URLSessionConfiguration.default
          configuration.protocolClasses = [SPSentryClientMockURLProtocol.self]
          return configuration
        }()
      )
    )!
  }

  override func tearDown() {
    client = nil
  }

  func testReturnsSuccess() {
    // given
    SPSentryClientMockURLProtocol.responseWithSuccess()

    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client!.captureFailedRequest(
      request: .init(
        url: .init(
          string: "http://any.com"
        )!
      ),
      response: .init(),
      responseData: "{}".data(using: .utf8)
    ) { data, response, error in

      // then
      if error != nil, data == nil {
        XCTFail("Expect to have a success")
        return
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testFailureReturnsError() {
    // given
    SPSentryClientMockURLProtocol.responseWithFailure()

    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client!.captureFailedRequest(
      request: .init(
        url: .init(
          string: "http://any.com"
        )!
      ),
      response: .init(),
      responseData: "{}".data(using: .utf8)
    ) { data, response, error in

      // then
      if error == nil, data != nil {
        XCTFail("Expect to have a failure")
        return
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testRequestWithSensitiveDataInEvent() {
    let tokenKey = "token"

    var request = URLRequest(
      url: URL(
        string: "http://any.com"
      )!
    )
    let body: [String: Any] = [
      tokenKey: "mock.token",
    ]
    request.httpBody = try! JSONSerialization.data(withJSONObject: body)

    // given
    SPSentryClientMockURLProtocol.responseWithSuccess()

    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client!.captureFailedRequest(
      request: request,
      response: URLResponse(),
      responseData: "{}".data(using: .utf8)
    ) { data, response, error in

      // then
      let failedRequestData = SPSentryClientMockURLProtocol.requestData!["request"]! as! [String: Any]
      let failedRequestBody = failedRequestData["data"] as! [String: Any]
      let tokenValue = failedRequestBody[tokenKey] as! String
      XCTAssertEqual(tokenValue, "***")
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }
}
