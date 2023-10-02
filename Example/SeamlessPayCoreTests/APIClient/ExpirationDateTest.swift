// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class ExpirationDateTest: XCTestCase {
  func testExpirationDateStringValue() {
    // given
    let expDate = ExpirationDate(month: 08, year: 39)

    // when
    let stringValue = expDate.stringValue

    // then
    XCTAssertEqual(stringValue, "8/39")
  }
}

