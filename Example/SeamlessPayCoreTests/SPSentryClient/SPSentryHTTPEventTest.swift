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
      request: .init(
        url: URL(string: "http://any.com")!
      ),
      response: .init(),
      responseData: "{}".data(using: .utf8),
      sentryClientConfig: SPSentryConfig(
        userId: "uiser.id",
        environment: "production"
      )
    )
    
    XCTAssertFalse(event.eventId.contains("-"))
  }
}
