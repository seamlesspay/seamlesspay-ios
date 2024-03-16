// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class SPInstallationTest: XCTestCase {
  func testSPInstallation() {
    // given
    let justCreatedId = SPInstallation.installationID

    // when
    let requestedIdAgain = SPInstallation.installationID

    // then
    XCTAssertNotEqual(justCreatedId, "undefined")
    XCTAssertEqual(justCreatedId, requestedIdAgain)
  }
}
