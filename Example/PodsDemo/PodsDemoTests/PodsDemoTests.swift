// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import PodsDemo
import SeamlessPayCore

final class PodsDemoTests: XCTestCase {
  func testSeamlessPaySDKSetup() {
    APIClient.shared.set(
      secretKey: "secret123",
      publishableKey: "publish456",
      environment: .sandbox
    )
  }

  func testImageExistence() {
    XCTAssertNotNil(SPImageLibrary.unknownCardCardImage())
    XCTAssertNotNil(SPImageLibrary.applePayCardImage())
  }
}