// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPayCore

final class APIClientConcurrencyTest: XCTestCase {
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

    client.set(secretKey: "sk_TEST", publishableKey: "pk_TEST", environment: .sandbox)

    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }

  private var urlToBeTested: String? {
    APIClientURLProtocolMock.testingRequest?.url?.absoluteString
  }

  private var hTTPMethodToBeTested: String? {
    APIClientURLProtocolMock.testingRequest!.httpMethod
  }

  // MARK: Tokenize
  func testAsyncTokenizeCreditCardRequest() async {
    // when
    _ = try? await client.tokenize(
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
    )

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox-pan-vault.seamlesspay.com/tokens")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }

  // MARK: Charge
  func testListChargesRequest() async {
    // when
    _ = try? await client.listCharges()

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox.seamlesspay.com/charges")
    XCTAssertEqual(hTTPMethodToBeTested, "GET")
  }

  func testAsyncGetChargeRequest() async {
    // when
    _ = try? await client.retrieveCharge(id: "test_charge_id")

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox.seamlesspay.com/charges/test_charge_id")
    XCTAssertEqual(hTTPMethodToBeTested, "GET")
  }

  func testAsyncVoidChargeRequest() async {
    // when
    _ = try? await client.voidCharge(id: "test_charge_id")

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox.seamlesspay.com/charges/test_charge_id")
    XCTAssertEqual(hTTPMethodToBeTested, "DELETE")
  }

  func testAsyncCreateChargeRequest() async {
    // when
    _ = try? await client.createCharge(token: "test_token", capture: true)

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox.seamlesspay.com/charges")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }

  // MARK: Verify
  func testAsyncVerifyRequest() async {
    // when
    _ = try? await client.verify(token: "test_token")

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox.seamlesspay.com/charges")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }

  // MARK: Refund

  func testAsyncCreateRefundRequest() async {
    // when
    _ = try? await client.createRefund(
      token: "test_token",
      amount: "101"
    )

    // then
    XCTAssertEqual(urlToBeTested, "https://sandbox.seamlesspay.com/refunds")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }
}
