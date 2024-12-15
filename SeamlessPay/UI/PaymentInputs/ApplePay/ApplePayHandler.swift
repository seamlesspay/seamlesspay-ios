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
  enum AuthState {
    case notStarted
    case finished
  }

  let apiClient: APIClient

  static var sdkConfiguration: SDKConfiguration?
  var authState: AuthState = .notStarted

  let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa,
  ]

  let merchantCapabilities: PKMerchantCapability = .capability3DS
  var paymentCompletion: ((ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>) -> Void)?
  var chargeRequest: ChargeRequest?

  public var delegate: ApplePayHandlerDelegate?
  var merchantIdentifier: String? {
    Self.sdkConfiguration?.applePayMerchantId
  }

  public init(
    config: ClientConfiguration
  ) {
    apiClient = APIClient(config: config)
    Task(priority: .userInitiated) {
      Self.sdkConfiguration = await SDKConfiguration(clientConfiguration: config)
    }
    super.init()
  }

  public init(
    awaitConfig: ClientConfiguration
  ) async {
    apiClient = APIClient(config: awaitConfig)
    Self.sdkConfiguration = await SDKConfiguration(clientConfiguration: awaitConfig)
    super.init()
  }

  public func charge(
    _ chargeRequest: ChargeRequest,
    completion: ((ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>) -> Void)?
  ) {
    guard let merchantIdentifier else {
      completion?(.failure(.missingMerchantIdentifier))
      return
    }

    paymentCompletion = completion
    self.chargeRequest = chargeRequest

    let request = PKPaymentRequest()
    request.countryCode = "US"
    request.currencyCode = "USD"

    request.supportedNetworks = supportedNetworks

    request.merchantIdentifier = merchantIdentifier
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

    applePayController.delegate = self
    applePayController.present { result in
//      DispatchQueue.main.async {}
    }
  }
}

public extension ApplePayHandler {
  var canPerformPayments: Bool {
    return PKPaymentAuthorizationController.canMakePayments() && merchantIdentifier != .none
  }
}

extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
  public func paymentAuthorizationControllerDidFinish(
    _ controller: PKPaymentAuthorizationController
  ) {
    controller.dismiss { [delegate] in
      dispatchToMainThread {
        delegate?.applePaySheetDidClose(self)

        if self.authState == .notStarted {
          self.paymentCompletion?(.canceled)
        }
      }
    }
  }

  public func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
  ) {
    authState = .finished

    guard let chargeRequest, let paymentCompletion else {
      completion(.init(status: .failure, errors: nil))
      return
    }
    completion(.init(status: .success, errors: nil))

    let digitalWallet = DigitalWallet(
      merchantId: "merchant.com.seamlesspay.wallet-stg",
      token: DigitalWallet.Token(
        paymentData: try? DigitalWallet.Token.PaymentData.decode(payment.token.paymentData),
        paymentMethod: .init(
          displayName: payment.token.paymentMethod.displayName,
          network: payment.token.paymentMethod.network?.rawValue,
          type: payment.token.paymentMethod.type.spName
        ),
        transactionIdentifier: payment.token.transactionIdentifier
      )
    )
    apiClient.tokenize(
      digitalWallet: digitalWallet,
      completion: { result in
        switch result {
        case let .success(paymentMethod):
          self.apiClient.createCharge(
            token: paymentMethod.token,
            request: chargeRequest,
            completion: { result in
              switch result {
              case let .success(paymentResponse):
//                completion(.init(status: .success, errors: nil))
                self.paymentCompletion?(.success(paymentResponse))
              case let .failure(error):
//                completion(.init(status: .failure, errors: [error]))
                self.paymentCompletion?(.failure(.seamlessPayError(error)))
              }
            }
          )
        case let .failure(error):
//          completion(.init(status: .failure, errors: [error]))
          self.paymentCompletion?(.failure(.seamlessPayError(error)))
        }
      }
    )
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

extension PKPaymentMethodType {
  var spName: String {
    switch self {
    case .credit:
      return "credit"
    case .debit:
      return "debit"
    case .prepaid:
      return "prepaid"
    case .store:
      return "store"
    case .unknown:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }
}
