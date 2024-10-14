// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay
@testable import SeamlessPayObjC

class SPCardValidatorStringIsNumericTest: XCTestCase {
  func testStringIsNumeric() {
    XCTAssertTrue(SPCardValidator.stringIsNumeric("1234567890"))
  }

  func testStringIsNumericWithEmptyString() {
    XCTAssertTrue(SPCardValidator.stringIsNumeric(""))
  }

  func testStringIsNumericWithNilString() {
    XCTAssertTrue(SPCardValidator.stringIsNumeric(nil))
  }

  func testStringIsNumericWithAlphaNumericString() {
    XCTAssertFalse(SPCardValidator.stringIsNumeric("123abc456"))
  }

  func testStringIsNumericWithSpecialCharacters() {
    XCTAssertFalse(SPCardValidator.stringIsNumeric("123!@#456"))
  }

  func testStringIsNumericWithWhitespace() {
    XCTAssertFalse(SPCardValidator.stringIsNumeric("123 456"))
  }

  func testStringIsNumericWithNegativeNumber() {
    XCTAssertFalse(SPCardValidator.stringIsNumeric("-123"))
  }

  func testStringIsNumericWithDecimalNumber() {
    XCTAssertFalse(SPCardValidator.stringIsNumeric("123.45"))
  }
}
