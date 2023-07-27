// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class SPSentryClientTest: XCTestCase {
  func testSPSentryURLRequest() {
    // given
    let event: SPSentryHTTPEvent = .init(
      exception: .init(
        values: []
      ),
      timestamp: Date().timeIntervalSince1970,
      release: "release",
      dist: "dist",
      level: "level",
      platform: "platform",
      contexts: .init(
        response: .init(
          headers: [:],
          statusCode: 101
        ),
        app: nil,
        os: nil,
        device: nil,
        culture: nil
      ),
      request: .init(
        url: "url",
        method: "method",
        fragment: nil,
        query: nil,
        headers: [:]
      ),
      eventId: "eventId",
      environment: "environment",
      user: .init(
        id: "id"
      )
    )

    let dsn: SPSentryDSN = .init(
      string: "https://test.secretkey@test.host/test.projectid"
    )!

    // when
    let request = SentryNSURLRequest.makeStoreRequest(
      from: event,
      dsn: dsn
    )

    // then
    XCTAssertNotNil(request)
    XCTAssertEqual(request!.httpMethod, "POST")

    XCTAssertNotNil(request!.allHTTPHeaderFields)
    let headers = request!.allHTTPHeaderFields!

    XCTAssertNotNil(headers["Content-Type"])
    XCTAssertNotNil(headers["Host"])
    XCTAssertNotNil(headers["User-Agent"])
    XCTAssertNotNil(headers["Content-Length"])
    XCTAssertNotNil(headers["X-Sentry-Auth"])

    var xSentryAuth = headers["X-Sentry-Auth"]!
    let supposedPrefix = "Sentry "
    XCTAssertTrue(xSentryAuth.hasPrefix(supposedPrefix))
    xSentryAuth = String(xSentryAuth.dropFirst(supposedPrefix.count))
    let xSentryAuthComponents = xSentryAuth.components(separatedBy: ",")

    XCTAssertEqual(
      Set(
        xSentryAuthComponents
      ),
      Set(
        [
          "sentry_version=7",
          "sentry_client=seamlesspay-ios-sentry-client/0.1",
          "sentry_key=test.secretkey",
        ]
      )
    )

    XCTAssertNotNil(request!.httpBody)
  }
}
