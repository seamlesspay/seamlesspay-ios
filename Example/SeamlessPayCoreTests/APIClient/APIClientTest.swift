// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class APIClientTest: XCTestCase {
  private var client: APIClient!

  override func setUp() {
    client = APIClient(
      session: .init(
        configuration: {
          let configuration = URLSessionConfiguration.default
          configuration.protocolClasses = [APIClientURLProtocolMock.self]
          return configuration
        }()
      )
    )

    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }

  // MARK: Tests
  func testShortVerifyRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.verify(token: "test_token") { result in

      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertEqual(url, "https://sandbox.seamlesspay.com/charges")
      XCTAssertEqual(method, "POST")

      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2020")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")

      let token = body["token"] as! String
      let capture = body["capture"] as! Bool

      // parameters
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(capture, false)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testFullVerifyRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.verify(
      token: "test_token",
      cvv: "test_cvv",
      currency: "test_currency",
      taxAmount: "test_taxAmount",
      taxExempt: true,
      tip: "test_tip",
      surchargeFeeAmount: "test_surchargeFeeAmount",
      description: "test_description",
      order: ["test_order_key": "test_order_value"],
      orderID: "test_orderID",
      poNumber: "test_poNumber",
      metadata: "test_metadata",
      descriptor: "test_descriptor",
      entryType: "test_entryType",
      idempotencyKey: "test_idempotencyKey"
    ) { result in

      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertEqual(url, "https://sandbox.seamlesspay.com/charges")
      XCTAssertEqual(method, "POST")

      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2020")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")

      let token = body["token"] as! String
      let capture = body["capture"] as! Bool
      let cvv = body["cvv"] as! String
      let currency = body["currency"] as! String
      let taxAmount = body["taxAmount"] as! String
      let taxExempt = body["taxExempt"] as! Bool
      let tip = body["tip"] as! String
      let surchargeFeeAmount = body["surchargeFeeAmount"] as! String
      let description = body["description"] as! String
      let order = body["order"] as! [String: String]

      let orderId = body["orderID"] as! String
      let poNumber = body["poNumber"] as! String
      let metadata = body["metadata"] as! String
      let descriptor = body["descriptor"] as! String
      let entryType = body["entryType"] as! String
      let idempotencyKey = body["idempotencyKey"] as! String

      // parameters
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(capture, false)
      XCTAssertEqual(cvv, "test_cvv")
      XCTAssertEqual(currency, "test_currency")
      XCTAssertEqual(taxAmount, "test_taxAmount")
      XCTAssertEqual(taxExempt, true)
      XCTAssertEqual(tip, "test_tip")
      XCTAssertEqual(surchargeFeeAmount, "test_surchargeFeeAmount")
      XCTAssertEqual(description, "test_description")
      XCTAssertEqual(order, ["test_order_key": "test_order_value"])
      XCTAssertEqual(orderId, "test_orderID")
      XCTAssertEqual(poNumber, "test_poNumber")
      XCTAssertEqual(metadata, "test_metadata")
      XCTAssertEqual(descriptor, "test_descriptor")
      XCTAssertEqual(entryType, "test_entryType")
      XCTAssertEqual(idempotencyKey, "test_idempotencyKey")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }
}
