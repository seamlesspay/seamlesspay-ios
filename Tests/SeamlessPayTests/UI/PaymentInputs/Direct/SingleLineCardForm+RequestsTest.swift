// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest

@testable import SeamlessPay

class SingleLineCardFormRequestsTest: XCTestCase {
  var sut: SingleLineCardForm!

  override func setUp() {
    super.setUp()
    sut = SingleLineCardForm()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  // MARK: - Tokenize Tests

  func testTokenize_SuccessfulTokenization() {
    // Given
    let apiClientMock = APIClientMock()
    sut.viewModel.apiClient = apiClientMock

    // When
    sut.tokenize { result in
      // Then
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.paymentToken, "mockedToken")
        XCTAssertEqual(payload.details.expDate, "01/25")
        XCTAssertEqual(payload.details.lastFour, "1234")
        XCTAssertEqual(payload.details.name, "John Doe")
        XCTAssertEqual(payload.details.paymentNetwork, .masterCard)
        XCTAssertEqual(payload.details.avsPostalCodeResult, .retry)
        XCTAssertEqual(payload.details.avsStreetAddressResult, .retry)
        XCTAssertEqual(payload.details.cvvResult, .retry)

      case .failure:
        XCTFail("Tokenization should succeed")
      }
    }
  }

  // MARK: - Charge Tests
  func testCharge_SuccessfulCharge() {
    // Given
    let apiClientMock = APIClientMock()
    sut.viewModel.apiClient = apiClientMock
    let request = ChargeRequest(amount: 1)

    // When
    sut.charge(request) { result in
      // Then
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.id, "mockedChargeID")
        XCTAssertEqual(payload.details.amount, 99)
        XCTAssertEqual(payload.details.status, .captured)
        XCTAssertEqual(payload.details.statusCode, "mocked_statusCode")
        XCTAssertEqual(payload.details.statusDescription, "mocked_statusDescription")
        XCTAssertEqual(payload.details.authCode, "mocked_authCode")
        XCTAssertEqual(payload.details.batchId, "mocked_batch")
        XCTAssertEqual(payload.details.transactionDate, "mocked_transactionDate")
        XCTAssertEqual(payload.details.surchargeFeeAmount, 101)
        XCTAssertEqual(payload.details.cardBrand, .masterCard)
        XCTAssertEqual(payload.details.lastFour, "mocked_lastFour")
        XCTAssertEqual(payload.details.cardBrand, .masterCard)
        XCTAssertEqual(payload.details.accountType, .credit)
        XCTAssertEqual(payload.details.currency, .usd)
        XCTAssertEqual(payload.details.expDate, "mocked_expDate")
        XCTAssertEqual(payload.details.tip, 3)
        XCTAssertEqual(payload.details.avsPostalCodeResult, .pass)
        XCTAssertEqual(payload.details.avsStreetAddressResult, .pass)
        XCTAssertEqual(payload.details.cvvResult, .pass)

      case .failure:
        XCTFail("Charge request should succeed")
      }
    }
  }

  // MARK: - Refund Tests
  func testRefund_SuccessfulResult() {
    // Given
    let apiClientMock = APIClientMock()
    sut.viewModel.apiClient = apiClientMock
    let request = RefundRequest(amount: 1)

    // When
    sut.refund(request) { result in
      // Then
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.id, "refund_id")
        XCTAssertEqual(payload.details.amount, 10001)
        XCTAssertEqual(payload.details.status, .authorized)
        XCTAssertEqual(payload.details.statusCode, "refund_statusCode")
        XCTAssertEqual(payload.details.statusDescription, "refund_statusDescription")
        XCTAssertEqual(payload.details.authCode, "refund_aute_code")
        XCTAssertEqual(payload.details.batchId, "refund_batch_id")
        XCTAssertEqual(payload.details.transactionDate, "refund_transactionDate")
        XCTAssertEqual(payload.details.cardBrand, .americanExpress)
        XCTAssertEqual(payload.details.lastFour, "refund_lastFour")
        XCTAssertEqual(payload.details.accountType, .credit)
        XCTAssertEqual(payload.details.currency, .cad)
        XCTAssertEqual(payload.details.expDate, .none)
        XCTAssertEqual(payload.details.tip, .none)
        XCTAssertEqual(payload.details.avsPostalCodeResult, .none)
        XCTAssertEqual(payload.details.avsStreetAddressResult, .none)
        XCTAssertEqual(payload.details.cvvResult, .none)
      case .failure:
        XCTFail("Charge request should succeed")
      }
    }
  }
}

// MARK: - Mocks
private class APIClientMock: APIClient {
  convenience init() {
    self.init(
      config: .init(environment: .sandbox, secretKey: "test_secret_key"),
      session: URLSession(configuration: .default)
    )
  }

  override func tokenize(
    paymentType: PaymentType,
    accountNumber: String,
    expDate: ExpirationDate? = nil,
    cvv: String? = nil,
    accountType: String? = nil,
    routing: String? = nil,
    pin: String? = nil,
    billingAddress: Address? = nil,
    name: String? = nil,
    completion: ((Result<PaymentMethod, SeamlessPayError>) -> Void)?
  ) {
    let paymentMethod = PaymentMethod(
      token: "mockedToken",
      expDate: "01/25",
      lastFour: "1234",
      name: "John Doe",
      paymentNetwork: .masterCard,
      paymentType: .creditCard,
      bankAccountType: "mocked_bankAccountType",
      routingNumber: "mocked_routingNumber",
      verificationResults: .init(avsPostalCode: .retry, avsStreetAddress: .retry, cvv: .retry),
      billingAddress: .init(
        line1: "mocked_line1",
        line2: "mocked_line2",
        country: "mocked_country",
        state: "mocked_state",
        city: "mocked_city",
        postalCode: "mocked_postalCode"
      )
    )
    completion?(.success(paymentMethod))
  }

  override func createCharge(
    token: String,
    amount: Int?,
    cvv: String? = nil,
    capture: Bool? = false,
    currency: String? = nil,
    taxAmount: Int? = nil,
    taxExempt: Bool? = nil,
    tip: Int? = nil,
    surchargeFeeAmount: Int? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderID: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    completion: ((Result<Charge, SeamlessPayError>) -> Void)?
  ) {
    let charge = Charge(
      id: "mockedChargeID",
      method: .charge,
      amount: 99,
      tip: 3,
      surchargeFeeAmount: 101,
      order: .init(
        items: [],
        shipFromPostalCode: "mocked_shipFromPostalCode",
        shippingAddress: .init(
          line1: "mocked_line1",
          line2: "mocked_line2",
          country: "mocked_country",
          state: "mocked_state",
          city: "mocked_city",
          postalCode: "mocked_postalCode"
        )
      ),
      currency: .usd,
      expDate: "mocked_expDate",
      lastFour: "mocked_lastFour",
      token: "mocked_token",
      transactionDate: "mocked_transactionDate",
      status: .captured,
      statusCode: "mocked_statusCode",
      statusDescription: "mocked_statusDescription",
      ipAddress: "mocked_ipAddress",
      authCode: "mocked_authCode",
      accountType: .credit,
      paymentType: .creditCard,
      paymentNetwork: .masterCard,
      batch: "mocked_batch",
      verificationResults: .init(avsPostalCode: .pass, avsStreetAddress: .pass, cvv: .pass),
      businessCard: false,
      fullyRefunded: false,
      refunds: [],
      createdAt: "mocked_createdAt",
      updatedAt: "mocked_updatedAt"
    )
    completion?(.success(charge))
  }

  override func createRefund(
    token: String,
    amount: Int,
    currency: String? = nil,
    descriptor: String? = nil,
    idempotencyKey: String? = nil,
    metadata: String? = nil,
    completion: ((Result<Refund, SeamlessPayError>) -> Void)?
  ) {
    completion?(
      .success(
        Refund(
          id: "refund_id",
          accountType: .credit,
          amount: 10001,
          authCode: "refund_aute_code",
          batchID: "refund_batch_id",
          createdAt: "refund_created_at",
          currency: .cad,
          events: [],
          idempotencyKey: "refund_idempotencyKey",
          ipAddress: "refund_ipAddress",
          lastFour: "refund_lastFour",
          metadata: "refund_metadata",
          method: .refund,
          paymentNetwork: .americanExpress,
          status: .authorized,
          statusCode: "refund_statusCode",
          statusDescription: "refund_statusDescription",
          token: "refund_token",
          transactionDate: "refund_transactionDate",
          updatedAt: "refund_updatedAt"
        )
      )
    )
  }
}
