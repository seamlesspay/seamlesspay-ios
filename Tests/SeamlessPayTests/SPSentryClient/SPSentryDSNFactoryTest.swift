// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class SPSentryDSNFactoryTest: XCTestCase {
  func testValidDSN() {
    // given
    let validURL = "https://test.secretkey@test.host/test.projectid"

    // when
    let dsn = SPSentryDSNFactory.dsn(urlString: validURL)

    // then
    XCTAssertNotNil(dsn)
    XCTAssertEqual(dsn!.url.absoluteString, validURL)
    XCTAssertEqual(dsn!.baseEndpoint.absoluteString, "https://test.host/api/test.projectid/")
    XCTAssertEqual(dsn!.storeEndpoint.absoluteString, "https://test.host/api/test.projectid/store/")
  }

  func testNotValidDSN() {
    // given
    let notValidURL = ""

    // when
    let dsn = SPSentryDSNFactory.dsn(urlString: notValidURL)

    // then
    XCTAssertNil(dsn)
  }
}
