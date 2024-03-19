// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class SPSentryURLRequestFactoryTest: XCTestCase {
  func testSPSentryURLRequestFactory() {
    // given
    let event: SPSentryHTTPEvent = SPSentryHTTPEventFactory.event(
      request: .init(
        url: URL(
          string: "http://any.com"
        )!
      ),
      response: .init(),
      responseData: "{}".data(using: .utf8),
      sentryClientConfig: SPSentryConfig(
        userId: "uiser.id",
        environment: "production"
      )
    )

    let dsn: SPSentryDSN = SPSentryDSNFactory.dsn(
      urlString: "https://test.secretkey@test.host/test.projectid"
    )!

    // when
    let request = SPSentryURLRequestFactory.request(event: event, dsn: dsn)

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
