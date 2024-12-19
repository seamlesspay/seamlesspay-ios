// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
import PassKit
@testable import SeamlessPay

class ApplePayHandlerTests: XCTestCase {
  var applePayHandler: ApplePayHandler!
  var mockDelegate: MockApplePayHandlerDelegate!

  override func setUp() async throws {
    try await super.setUp()
    let sdkConfiguration = await SDKConfiguration(
      clientConfiguration: ClientConfiguration(
        environment: .production,
        secretKey: "sk_TEST"
      )
    )
    mockDelegate = MockApplePayHandlerDelegate()
    applePayHandler = ApplePayHandler(sdkConfiguration: sdkConfiguration)
    applePayHandler.delegate = mockDelegate
  }

  override func tearDown() {
    applePayHandler = nil
    mockDelegate = nil
    super.tearDown()
  }

  func testPresentApplePayForMissingMerchantIdentifier() {
    let chargeRequest = ChargeRequest(amount: 100)
    let expectation = self.expectation(description: "Completion called")

    applePayHandler.presentApplePayFor(chargeRequest) { result in
      switch result {
      case let .failure(error):
        switch error {
        case .missingMerchantIdentifier:
          break
        default:
          XCTFail("Expected missingMerchantIdentifier error in failure")
        }
      default:
        XCTFail("Expected failure with missingMerchantIdentifier error")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testHandlePaymentCompletion() {
    let expectation = self.expectation(description: "Completion called")
    let paymentResponse = PaymentResponse(
      id: UUID().uuidString,
      paymentToken: UUID().uuidString,
      details: .init(
        accountType: .none,
        amount: .none,
        authCode: .none,
        batchId: .none,
        cardBrand: .none,
        currency: .none,
        expDate: .none,
        lastFour: .none,
        status: .none,
        statusCode: .none,
        statusDescription: .none,
        surchargeFeeAmount: .none,
        tip: .none,
        transactionDate: .none,
        avsPostalCodeResult: .none,
        avsStreetAddressResult: .none,
        cvvResult: .none
      )
    )

    applePayHandler.paymentCompletion = { result in
      switch result {
      case .success:
        break
      default:
        XCTFail("Expected success with paymentResponse")
      }
      expectation.fulfill()
    }

    applePayHandler.handlePaymentCompletion(.success(paymentResponse))

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testPaymentAuthorizationControllerDidFinish() {
    let controller = PKPaymentAuthorizationController(paymentRequest: PKPaymentRequest())

    applePayHandler.paymentAuthorizationControllerDidFinish(controller)

    XCTAssertTrue(mockDelegate.applePaySheetDidCloseCalled)
  }

  func testChargeRequestMissed() {
    let controller = PKPaymentAuthorizationController(paymentRequest: PKPaymentRequest())
    let payment = PKPayment()
    let expectation = self.expectation(description: "Completion called")

    applePayHandler.paymentAuthorizationController(
      controller,
      didAuthorizePayment: payment
    ) { result in
      XCTAssertEqual(result.status, .failure)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }
}

class MockApplePayHandlerDelegate: ApplePayHandlerDelegate {
  var applePaySheetDidCloseCalled = false

  func applePaySheetDidClose(_ handler: ApplePayHandler) {
    applePaySheetDidCloseCalled = true
  }
}
