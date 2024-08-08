// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class APIClientWithProxyAccountIdTest: XCTestCase {
  private var client: APIClient!

  override func setUp() {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [APIClientURLProtocolMock.self]
    let session = URLSession(configuration: configuration)

    client = APIClient(
      config: .init(environment: .sandbox, secretKey: "sk_TEST", proxyAccountId: "MRT_TEST"),
      session: session
    )

    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }

  // MARK: - Tests
  // MARK: Tokenize
  func testTokenizeCreditCardRequestWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")
    // when
    client.tokenize(
      paymentType: .creditCard,
      accountNumber: "test_accountNumber",
      expDate: .init(month: 7, year: 33),
      cvv: "test_cvv",
      accountType: "test_accountType",
      routing: "test_routing",
      pin: "test_ping",
      billingAddress: .init(
        line1: "test_line1",
        line2: "test_line2",
        country: "test_country",
        state: "test_state",
        city: "test_city",
        postalCode: "test_postalCode"
      ),
      name: "test_name"
    ) { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!

      // headers
      XCTAssertEqual(headers["SeamlessPay-Account"], "MRT_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  // MARK: Charge
  func testListChargesRequestWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.listCharges { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!

      // headers
      XCTAssertNil(headers["SeamlessPay-Account"])

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testGetChargeRequestWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.retrieveCharge(id: "test_charge_id") { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!

      // headers
      XCTAssertNil(headers["SeamlessPay-Account"])

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testVoidChargeRequestWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.voidCharge(id: "test_charge_id") { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!

      // headers
      XCTAssertEqual(headers["SeamlessPay-Account"], "MRT_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testCreateChargeRequestWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.createCharge(
      token: "test_token",
      amount: "100",
      cvv: "test_cvv",
      capture: true,
      currency: "test_currency",
      taxAmount: "test_taxAmount",
      taxExempt: false,
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

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!

      // headers
      XCTAssertEqual(headers["SeamlessPay-Account"], "MRT_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  // MARK: Refund
  func testCreateRefundRequestWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.createRefund(
      token: "test_token",
      amount: "101"
    ) { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!

      // headers
      XCTAssertEqual(headers["SeamlessPay-Account"], "MRT_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }
}
