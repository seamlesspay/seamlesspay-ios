// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class NSDecimalNumberFromUnitsTests: XCTestCase {
  func testPositiveIntegers() {
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(1),
      NSDecimalNumber(string: "0.01"),
      "Failed for 1 unit"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(10),
      NSDecimalNumber(string: "0.10"),
      "Failed for 10 units"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(100),
      NSDecimalNumber(string: "1.00"),
      "Failed for 100 units"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(250),
      NSDecimalNumber(string: "2.50"),
      "Failed for 250 units"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(1505),
      NSDecimalNumber(string: "15.05"),
      "Failed for 1505 units"
    )
  }

  func testZero() {
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(0),
      NSDecimalNumber(string: "0.00"),
      "Failed for 0 units"
    )
  }

  func testNegativeIntegers() {
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(-1),
      NSDecimalNumber(string: "-0.01"),
      "Failed for -1 unit"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(-100),
      NSDecimalNumber(string: "-1.00"),
      "Failed for -100 units"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(-1505),
      NSDecimalNumber(string: "-15.05"),
      "Failed for -1505 units"
    )
  }

  func testLargeNumbers() {
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(1_000_000),
      NSDecimalNumber(string: "10000.00"),
      "Failed for 1 million units"
    )
  }

  func testPrecision() {
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(1).description,
      "0.01",
      "Failed precision check for 1 unit"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(10).description,
      "0.1",
      "Failed precision check for 10 units"
    )
    XCTAssertEqual(
      NSDecimalNumber.fromUnits(100).description,
      "1",
      "Failed precision check for 100 units"
    )
  }
}
