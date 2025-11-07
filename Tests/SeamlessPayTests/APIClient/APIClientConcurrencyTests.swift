// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class APIClientConcurrencyTest: XCTestCase {
  private var client: APIClient!

  override func setUp() {
    client = APIClient(
      config: .init(environment: .production, secretKey: "sk_TEST"),
      session: {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [APIClientURLProtocolMock.self]
        return .init(configuration: configuration)
      }()
    )

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
    _ = await client.tokenize(
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
    XCTAssertEqual(urlToBeTested, "https://pan-vault.seamlesspay.com/tokens")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }

  // MARK: Charge
  func testListChargesRequest() async {
    // when
    _ = await client.listCharges()

    // then
    XCTAssertEqual(urlToBeTested, "https://api.seamlesspay.com/charges")
    XCTAssertEqual(hTTPMethodToBeTested, "GET")
  }

  func testAsyncGetChargeRequest() async {
    // when
    _ = await client.retrieveCharge(id: "test_charge_id")

    // then
    XCTAssertEqual(urlToBeTested, "https://api.seamlesspay.com/charges/test_charge_id")
    XCTAssertEqual(hTTPMethodToBeTested, "GET")
  }

  func testAsyncVoidChargeRequest() async {
    // when
    _ = await client.voidCharge(id: "test_charge_id")

    // then
    XCTAssertEqual(urlToBeTested, "https://api.seamlesspay.com/charges/test_charge_id")
    XCTAssertEqual(hTTPMethodToBeTested, "DELETE")
  }

  func testAsyncCreateChargeRequest() async {
    // when
    _ = await client.createCharge(token: "test_token", amount: 100)

    // then
    XCTAssertEqual(urlToBeTested, "https://api.seamlesspay.com/charges")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }

  // MARK: Refund

  func testAsyncCreateRefundRequest() async {
    // when
    _ = await client.createRefund(
      token: "test_token",
      amount: 101
    )

    // then
    XCTAssertEqual(urlToBeTested, "https://api.seamlesspay.com/refunds")
    XCTAssertEqual(hTTPMethodToBeTested, "POST")
  }
}
