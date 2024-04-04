// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest

// import SeamlessPay
@testable import SeamlessPay

class SPPaymentCardTextFieldRequestsTest: XCTestCase {
  var sut: SPPaymentCardTextField!

  override func setUp() {
    super.setUp()
    sut = SPPaymentCardTextField()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  // MARK: - Tokenize Tests

  func testTokenize_SuccessfulTokenization() {
    // Given
    let apiClientMock = APIClientMock()
    sut.apiClient = apiClientMock

    // When
    sut.tokenize { result in
      // Then
      switch result {
      case let .success(tokenize):
        switch tokenize.details {
        case let .creditCard(name, lastFour, expirationDate, paymentNetwork):
          XCTAssertEqual(expirationDate, "01/25")
          XCTAssertEqual(lastFour, "1234")
          XCTAssertEqual(name, "John Doe")
          XCTAssertEqual(paymentNetwork, .masterCard)
        default:
          XCTFail("Wrong payment details")
        }
      case .failure:
        XCTFail("Tokenization should succeed")
      }
    }
  }

  // MARK: - Submit Tests

  func testSubmit_SuccessfulSubmission() {
    // Given
    let apiClientMock = APIClientMock()
    sut.apiClient = apiClientMock
    let request = PaymentRequest(amount: "1")

    // When
    sut.submit(request) { result in
      // Then
      switch result {
      case let .success(payment):
        switch payment.details {
        case let .creditCard(
          accountType,
          amount,
          currency,
          authCode,
          batchId,
          expDate,
          lastFour,
          cardBrand,
          status,
          statusCode,
          statusDescription,
          surchargeFeeAmount,
          tip,
          transactionDate
        ):
          XCTAssertEqual(amount, "99")
          XCTAssertEqual(currency, .usd)
          XCTAssertEqual(status, .captured)
          XCTAssertEqual(statusCode, "mocked_statusCode")
          XCTAssertEqual(statusDescription, "mocked_statusDescription")
          XCTAssertEqual(authCode, "mocked_authCode")
          XCTAssertEqual(accountType, .credit)
          XCTAssertEqual(batchId, "mocked_batch")
          XCTAssertEqual(expDate, "mocked_expDate")
          XCTAssertEqual(tip, "mocked_tip")
          XCTAssertEqual(transactionDate, "mocked_transactionDate")
          XCTAssertEqual(surchargeFeeAmount, "mocked_surchargeFeeAmount")
          XCTAssertEqual(cardBrand, .masterCard)
          XCTAssertEqual(lastFour, "mocked_lastFour")
        default:
          XCTFail("Wrong payment details")
        }
      case .failure:
        XCTFail("Submission should succeed")
      }
    }
  }
}

// MARK: - Mocks
private class APIClientMock: APIClient {
  convenience init() {
    self.init(
      authorization: .init(environment: .sandbox, secretKey: "test_secret_key"),
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
      verificationResults: .init(avsPostalCode: .pass, avsStreetAddress: .pass, cvv: .pass),
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
    cvv: String? = nil,
    capture: Bool,
    currency: String? = nil,
    amount: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
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
      amount: "99",
      tip: "mocked_tip",
      surchargeFeeAmount: "mocked_surchargeFeeAmount",
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
}
