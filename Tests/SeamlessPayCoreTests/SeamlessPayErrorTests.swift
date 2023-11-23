// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class SeamlessPayErrorTests: XCTestCase {
  func testErrorWithNilInput() {
    // given
    // when
    let error = SeamlessPayError.fromFailedSessionTask(
      data: nil,
      error: nil
    )

    // then
    guard case let .apiError(apiError) = error else {
      XCTAssert(false, "Wrong seamless pay error subtype")
      return
    }

    XCTAssertEqual(apiError.code, 29)
    XCTAssertEqual(apiError.domain, "api.seamlesspay.com")
    XCTAssertEqual(apiError.localizedDescription, "Unknown Error")
  }

  func testErrorWithErrorAsInput() {
    // given
    struct SessionTaskErrorMock: Error {
      let reason = "reason"
    }

    // when
    let error = SeamlessPayError.fromFailedSessionTask(
      data: nil,
      error: SessionTaskErrorMock()
    )

    // then
    guard case .sessionTaskError = error else {
      XCTAssert(false, "Wrong seamless pay error subtype")
      return
    }
  }

  func testErrorWithDataAsInput() {
    // given
    let data = """
    {
      "code": 88,
      "message": "Test Error Message"
    }
    """.data(using: .utf8)

    // when
    let error = SeamlessPayError.fromFailedSessionTask(
      data: data,
      error: nil
    )

    // then
    guard case let .apiError(apiError) = error else {
      XCTAssert(false, "Wrong seamless pay error subtype")
      return
    }

    XCTAssertEqual(apiError.code, 88)
    XCTAssertEqual(apiError.domain, "api.seamlesspay.com")
    XCTAssertFalse(apiError.localizedDescription.isEmpty)
  }
}
