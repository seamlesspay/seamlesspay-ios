// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class APIOperationTest: XCTestCase {
  func testAPIOperation() {
    // Tokens
    XCTAssertEqual(APIOperation.createToken.method, .post)
    XCTAssertEqual(APIOperation.createToken.path, "/tokens")

    // Charges
    XCTAssertEqual(APIOperation.createCharge.method, .post)
    XCTAssertEqual(APIOperation.createCharge.path, "/charges")

    XCTAssertEqual(APIOperation.listCharges.method, .get)
    XCTAssertEqual(APIOperation.listCharges.path, "/charges")

    XCTAssertEqual(APIOperation.retrieveCharge(id: "test_id").method, .get)
    XCTAssertEqual(APIOperation.retrieveCharge(id: "test_id").path, "/charges/test_id")

    XCTAssertEqual(APIOperation.voidCharge(id: "test_id").method, .delete)
    XCTAssertEqual(APIOperation.voidCharge(id: "test_id").path, "/charges/test_id")

    // Customers
    XCTAssertEqual(APIOperation.createCustomer.method, .post)
    XCTAssertEqual(APIOperation.createCustomer.path, "/customers")

    XCTAssertEqual(APIOperation.retrieveCustomer(id: "test_id").method, .get)
    XCTAssertEqual(APIOperation.retrieveCustomer(id: "test_id").path, "/customers/test_id")

    XCTAssertEqual(APIOperation.updateCustomer(id: "test_id").method, .put)
    XCTAssertEqual(APIOperation.updateCustomer(id: "test_id").path, "/customers/test_id")
  }
}
