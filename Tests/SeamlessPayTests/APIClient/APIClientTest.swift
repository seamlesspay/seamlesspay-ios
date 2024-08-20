// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class APIClientTest: XCTestCase {
  private var client: APIClient!

  override func setUp() {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [APIClientURLProtocolMock.self]
    let session = URLSession(configuration: configuration)

    client = APIClient(
      config: .init(environment: .production, secretKey: "sk_TEST", proxyAccountId: .none),
      session: session
    )

    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }

  // MARK: - Tests
  // MARK: Tokenize
  func testTokenizeCreditCardRequest() {
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
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertEqual(url, "https://pan-vault.seamlesspay.com/tokens")
      XCTAssertEqual(method, "POST")

      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")

      let cvv = body["cvv"] as! String
      let accountNumber = body["accountNumber"] as! String
      let billingAddress = body["billingAddress"] as! [String: String]
      let expDate = body["expDate"] as! String
      let name = body["name"] as! String
      let paymentType = body["paymentType"] as! String

      // parameters
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertEqual(cvv, "test_cvv")

      XCTAssertEqual(accountNumber, "test_accountNumber")
      XCTAssertEqual(expDate, "7/33")
      XCTAssertEqual(name, "test_name")
      XCTAssertEqual(paymentType, "credit_card")

      XCTAssertNil(body["bankAccountType"])
      XCTAssertNil(body["routingNumber"])
      XCTAssertNil(body["pinNumber"])

      // billing address
      let postalCode = billingAddress["postalCode"]!
      let country = billingAddress["country"]!
      let city = billingAddress["city"]!
      let line1 = billingAddress["line1"]!
      let line2 = billingAddress["line2"]!
      let state = billingAddress["state"]!

      XCTAssertEqual(postalCode, "test_postalCode")
      XCTAssertEqual(country, "test_country")
      XCTAssertEqual(city, "test_city")
      XCTAssertEqual(line1, "test_line1")
      XCTAssertEqual(line2, "test_line2")
      XCTAssertEqual(state, "test_state")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testTokenizeGiftCardRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.tokenize(
      paymentType: .giftCard,
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
      let body = request.bodyStreamAsJSON()!

      let pinNumber = body["pinNumber"] as! String

      // parameters
      XCTAssertEqual(pinNumber, "test_ping")

      XCTAssertNil(body["cvv"])
      XCTAssertNil(body["expDate"])
      XCTAssertNil(body["bankAccountType"])
      XCTAssertNil(body["routingNumber"])

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testTokenizeAchRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.tokenize(
      paymentType: .ach,
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
      let body = request.bodyStreamAsJSON()!

      let bankAccountType = body["bankAccountType"] as! String
      let routing = body["routingNumber"] as! String

      // parameters
      XCTAssertEqual(bankAccountType, "test_accountType")
      XCTAssertEqual(routing, "test_routing")

      XCTAssertNil(body["cvv"])
      XCTAssertNil(body["expDate"])
      XCTAssertNil(body["pinNumber"])

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  // MARK: Charge
  func testListChargesRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.listCharges { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges")
      XCTAssertEqual(method, "GET")

      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testGetChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.retrieveCharge(id: "test_charge_id") { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges/test_charge_id")
      XCTAssertEqual(method, "GET")

      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testVoidChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.voidCharge(id: "test_charge_id") { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges/test_charge_id")
      XCTAssertEqual(method, "DELETE")

      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }

  func testCreateChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.createCharge(
      token: "test_token",
      amount: 100,
      cvv: "test_cvv",
      capture: true,
      currency: "test_currency",
      taxAmount: 1,
      taxExempt: false,
      tip: "test_tip",
      surchargeFeeAmount: 12,
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
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertEqual(url, "https://api.seamlesspay.com/charges")
      XCTAssertEqual(method, "POST")

      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")

      let token = body["token"] as! String
      let capture = body["capture"] as! Bool
      let cvv = body["cvv"] as! String
      let currency = body["currency"] as! String
      let taxAmount = body["taxAmount"] as! Int
      let taxExempt = body["taxExempt"] as! Bool
      let tip = body["tip"] as! String
      let surchargeFeeAmount = body["surchargeFeeAmount"] as! Int
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
      XCTAssertEqual(capture, true)
      XCTAssertEqual(cvv, "test_cvv")
      XCTAssertEqual(currency, "test_currency")
      XCTAssertEqual(taxAmount, 1)
      XCTAssertEqual(taxExempt, false)
      XCTAssertEqual(tip, "test_tip")
      XCTAssertEqual(surchargeFeeAmount, 12)
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

  // MARK: Refund
  func testCreateRefundRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    // when
    client.createRefund(
      token: "test_token",
      amount: 101
    ) { result in

      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!

      XCTAssertEqual(url, "https://api.seamlesspay.com/refunds")
      XCTAssertEqual(method, "POST")

      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")

      let token = body["token"] as! String
      let amount = body["amount"] as! Int

      // parameters
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(amount, 101)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.5)
  }
}
