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
  private enum PaymentStatus {
    case notStarted
    case authorized
  }

  private let apiClient: APIClient
  private var paymentStatus: PaymentStatus?
  private static var sdkConfiguration: SDKConfiguration?

  private let countryCode = "US"
  private let currencyCode = "USD"
  private let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa,
  ]

  private let merchantCapabilities: PKMerchantCapability = .capability3DS
  private var chargeRequest: ChargeRequest?

  var paymentCompletion: ((ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>) -> Void)?

  var merchantIdentifier: String? {
    Self.sdkConfiguration?.data?.applePay?.merchantId
  }

  var merchantName: String? {
    Self.sdkConfiguration?.data?.seamlessPay.merchantName
  }

  public var delegate: ApplePayHandlerDelegate?
  public var canPerformPayments: Bool {
    PKPaymentAuthorizationController.canMakePayments() && merchantIdentifier != .none
  }

  public init(sdkConfiguration: SDKConfiguration) {
    apiClient = APIClient(config: sdkConfiguration.clientConfiguration)
    Self.sdkConfiguration = sdkConfiguration
    super.init()
  }

  public init(config: ClientConfiguration) async {
    apiClient = APIClient(config: config)
    Self.sdkConfiguration = await SDKConfiguration(clientConfiguration: config)
    super.init()
  }

  public func presentApplePayFor(
    _ chargeRequest: ChargeRequest,
    completion: @escaping ((ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>)
      -> Void)
  ) {
    guard let merchantIdentifier, let merchantName else {
      completion(.failure(.missingMerchantIdentifier))
      return
    }

    guard paymentStatus == .none else {
      completion(.failure(.paymentProcessingInProgress))
      return
    }

    paymentStatus = .notStarted

    paymentCompletion = completion
    self.chargeRequest = chargeRequest

    let request = PKPaymentRequest()
    request.countryCode = countryCode
    request.currencyCode = currencyCode

    request.supportedNetworks = supportedNetworks

    request.merchantIdentifier = merchantIdentifier
    request.merchantCapabilities = merchantCapabilities

    request.paymentSummaryItems = [
      PKPaymentSummaryItem(
        label: merchantName,
        amount: .fromUnits(chargeRequest.amount)
      ),
    ]

    let applePayController = PKPaymentAuthorizationController(
      paymentRequest: request
    )

    applePayController.delegate = self
    applePayController.present { _ in }
  }

  func handlePaymentCompletion(
    _ result: ApplePayHandlerResult<PaymentResponse, ApplePayHandlerError>
  ) {
    paymentStatus = .none
    paymentCompletion?(result)
  }
}

// MARK: - PKPaymentAuthorizationControllerDelegate
extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
  public func paymentAuthorizationControllerDidFinish(
    _ controller: PKPaymentAuthorizationController
  ) {
    controller.dismiss { [delegate] in
      dispatchToMainThread {
        delegate?.applePaySheetDidClose(self)

        if self.paymentStatus == .notStarted {
          self.handlePaymentCompletion(.canceled)
        }
      }
    }
  }

  public func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
  ) {
    paymentStatus = .authorized

    guard let chargeRequest else {
      paymentStatus = .none
      completion(.init(status: .failure, errors: nil))
      return
    }

    completion(.init(status: .success, errors: nil))

    let digitalWallet = DigitalWallet(
      merchantId: merchantIdentifier,
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
                self.handlePaymentCompletion(.success(paymentResponse))
              case let .failure(error):
                self.handlePaymentCompletion(.failure(.seamlessPayError(error)))
              }
            }
          )
        case let .failure(error):
          self.handlePaymentCompletion(.failure(.seamlessPayError(error)))
        }
      }
    )
  }
}

private extension PKPaymentMethodType {
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
    case .eMoney:
      return "eMoney"
    case .unknown:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }
}
