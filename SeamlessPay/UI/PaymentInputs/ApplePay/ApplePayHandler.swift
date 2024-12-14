// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import PassKit

public protocol ApplePayHandlerDelegate {
  func applePaySheetDidClose(_ handler: ApplePayHandler)
}

public class ApplePayHandler: NSObject {
  enum PaymentState {
    case notStarted
    case pending
    case error
    case success
  }

  var apiClient: APIClient?
  var state: PaymentState = .notStarted
  var paymentCompletion: ((ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>) -> Void)?

  let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa,
  ]

  let merchantCapabilities: PKMerchantCapability = .capability3DS

  public var delegate: ApplePayHandlerDelegate?
  public init(
    config: ClientConfiguration
  ) {
    super.init()
    apiClient = APIClient(config: config)
  }

  public func charge(
    _ chargeRequest: ChargeRequest,
    completion: ((ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>) -> Void)?
  ) {
    let request = PKPaymentRequest()
    request.countryCode = "US"
    request.currencyCode = "USD"

    request.merchantIdentifier = "merchant.com.seamlesspay.wallet-stg"
    request.supportedNetworks = supportedNetworks
    request.merchantCapabilities = merchantCapabilities

    request.paymentSummaryItems = [
      PKPaymentSummaryItem(
        label: "Total",
        amount: NSDecimalNumber(string: chargeRequest.amount.amountDescription)
      ),
    ]

    let applePayController = PKPaymentAuthorizationController(
      paymentRequest: request
    )

    paymentCompletion = completion
    applePayController.delegate = self
    applePayController.present { result in
//      DispatchQueue.main.async {}
    }
  }
}

public extension ApplePayHandler {
  var canPerformPayments: Bool {
    PKPaymentAuthorizationController.canMakePayments()
  }
}

extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
  public func paymentAuthorizationControllerDidFinish(
    _ controller: PKPaymentAuthorizationController
  ) {
    delegate?.applePaySheetDidClose(self)

    controller.dismiss { [weak self] in
      guard let self else { return }
      if state == .notStarted {
        paymentCompletion?(.canceled)
      }
    }
  }

  public func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
  ) {
    print("paymentAuthorizationController didAuthorizePayment")
    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
  }
}

extension Int {
  var amountDescription: String {
    let subunits = 100
    let mainUnits = self / subunits
    let subUnits = self % subunits
    return "\(mainUnits).\(subUnits)"
  }
}
