// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import PodsDemo
import SeamlessPay

final class PodsDemoTests: XCTestCase {
  func testSeamlessPaySDKSetup() {
    let client = APIClient(
      authorization: .init(environment: .sandbox, secretKey: "secret_key")
    )
  }

  func testImageExistence() {
    XCTAssertNotNil(SPImageLibrary.unknownCardCardImage())
    XCTAssertNotNil(SPImageLibrary.applePayCardImage())
  }
}
