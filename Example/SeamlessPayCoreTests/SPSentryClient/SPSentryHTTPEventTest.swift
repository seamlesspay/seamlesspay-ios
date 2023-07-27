// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class SPSentryHTTPEventTest: XCTestCase {
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

    XCTAssertFalse(event.eventId.contains("-"))
  }
}
