// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class APIErrorTests: XCTestCase {
  func testAPIErrorDecoding() throws {
    let json = """
    {
        "code": 422,
        "data": {
            "errors": [
                {
                    "fieldName": "test_error_field_name",
                    "message": "test_error_message"
                }
            ],
            "statusCode": "test_statusCode",
            "statusDescription": "test_statusDescription"
        },
        "message": "test_message",
        "name": "test_name",
        "requestId": "101",
        "status": 0
    }
    """.data(using: .utf8)!

    let apiError = try APIError.decode(json)

    XCTAssertEqual(apiError.kind, .unprocessable)
    XCTAssertEqual(apiError.statusCode, "test_statusCode")
    XCTAssertEqual(apiError.statusDescription, "test_statusDescription")
    XCTAssertEqual(apiError.errors?.first?.message, "test_error_message")
    XCTAssertEqual(apiError.errors?.first?.fieldName, "test_error_field_name")
  }

  func testAPIErrorWithErrorsWithoutErrorFieldName() throws {
    let json = """
    {
        "code": 422,
        "data": {
            "errors": [
                {
                    "message": "test_error_message"
                }
            ],
            "statusCode": "test_statusCode",
            "statusDescription": "test_statusDescription"
        },
        "message": "test_message",
        "name": "test_name",
        "requestId": "101",
        "status": 0
    }
    """.data(using: .utf8)!

    let apiError = try APIError.decode(json)

    XCTAssertEqual(apiError.kind, .unprocessable)
    XCTAssertEqual(apiError.statusCode, "test_statusCode")
    XCTAssertEqual(apiError.statusDescription, "test_statusDescription")
    XCTAssertEqual(apiError.errors?.first?.message, "test_error_message")
    XCTAssertNil(apiError.errors?.first?.fieldName)
  }

  func testAPIErrorWithoutErrors() throws {
    let json = """
        {
            "code": 422,
            "data": {
                "statusCode": "test_statusCode",
                "statusDescription": "test_statusDescription"
            },
            "message": "test_message",
            "name": "test_name",
            "requestId": "101",
            "status": 0
        }
    """.data(using: .utf8)!

    let apiError = try APIError.decode(json)

    XCTAssertEqual(apiError.kind, .unprocessable)
    XCTAssertEqual(apiError.statusCode, "test_statusCode")
    XCTAssertEqual(apiError.statusDescription, "test_statusDescription")
    XCTAssertNil(apiError.errors)
  }

  func testUnknownAPIError() {
    let unknownError = APIError.unknown

    XCTAssertEqual(unknownError.kind, .unknown)
    XCTAssertNil(unknownError.statusCode)
    XCTAssertNil(unknownError.statusDescription)
    XCTAssertNil(unknownError.errors)
  }

  func testAPIErrorDecodingForAllKinds() throws {
    let errorKinds: [(Int, APIError.ErrorKind)] = [
      (400, .badRequest),
      (401, .unauthorized),
      (402, .declined),
      (403, .forbidden),
      (422, .unprocessable),
      (429, .rateLimit),
      (500, .internal),
      (503, .unavailable),
      (999, .unknown), // Ensuring unknown codes map correctly
    ]

    for (code, expectedKind) in errorKinds {
      let json = """
      {
          "code": \(code),
          "data": {
              "errors": [
                  {
                      "fieldName": "test_error_field_name",
                      "message": "test_error_message"
                  }
              ],
              "statusCode": "test_statusCode",
              "statusDescription": "test_statusDescription"
          },
          "message": "test_message",
          "name": "test_name",
          "requestId": "101",
          "status": 0
      }
      """.data(using: .utf8)!

      let apiError = try APIError.decode(json)

      XCTAssertEqual(apiError.kind, expectedKind, "Failed for code \(code)")
    }
  }
}
