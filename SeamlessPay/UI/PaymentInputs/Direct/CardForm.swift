// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Public
// MARK: Init with Authorization model
public extension CardForm {
  convenience init(config: ClientConfiguration, fieldOptions: FieldOptions = .default) {
    self.init()
    apiClient = .init(config: config)
    setFieldOptions(fieldOptions)
  }

  private func setFieldOptions(_ fieldOptions: FieldOptions) {
    setCVCDisplayConfig(fieldOptions.cvv.display)
    setPostalCodeDisplayConfig(fieldOptions.postalCode.display)
  }
}

// MARK: Tokenize
public extension CardForm {
  func tokenize(
    completion: ((Result<TokenizeResponse, SeamlessPayError>) -> Void)?
  ) {
    apiClient?.tokenize(
      paymentType: .creditCard,
      accountNumber: viewModel?.cardNumber ?? .init(),
      expDate: expDate,
      cvv: viewModel?.cvc,
      accountType: .none,
      routing: .none,
      pin: .none,
      billingAddress: .init(
        line1: .none,
        line2: .none,
        country: .none,
        state: .none,
        city: .none,
        postalCode: viewModel?.postalCode
      ),
      name: .none,
      completion: { result in
        completion?(
          result.map {
            .init(
              paymentToken: $0.token,
              details: .init(
                expDate: $0.expDate,
                lastFour: $0.lastFour,
                name: $0.name,
                paymentNetwork: $0.paymentNetwork
              )
            )
          }
        )
      }
    )
  }

  func tokenize() async -> Result<TokenizeResponse, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      tokenize { result in
        continuation.resume(returning: result)
      }
    }
  }
}

// MARK: - Charge
public extension CardForm {
  func charge(
    _ request: ChargeRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    tokenize { result in
      switch result {
      case let .success(paymentMethod):
        self.apiClient?.createCharge(
          token: paymentMethod.paymentToken,
          amount: request.amount,
          cvv: self.viewModel?.cvc,
          capture: request.capture,
          currency: request.currency,
          taxAmount: request.taxAmount,
          taxExempt: request.taxExempt,
          tip: request.tip,
          surchargeFeeAmount: request.surchargeFeeAmount,
          description: request.description,
          order: request.order,
          orderID: request.orderID,
          poNumber: request.poNumber,
          metadata: request.metadata,
          descriptor: request.descriptor,
          entryType: request.entryType,
          idempotencyKey: request.idempotencyKey,
          completion: { result in
            completion?(
              result.map {
                .init(
                  id: $0.id,
                  paymentToken: paymentMethod.paymentToken,
                  details: .init(
                    amount: $0.amount,
                    authCode: $0.authCode,
                    batchId: $0.batch,
                    cardBrand: $0.paymentNetwork,
                    lastFour: $0.lastFour,
                    status: $0.status,
                    statusCode: $0.statusCode,
                    statusDescription: $0.statusDescription,
                    surchargeFeeAmount: $0.surchargeFeeAmount,
                    transactionDate: $0.transactionDate
                  )
                )
              }
            )
          }
        )
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func charge(
    _ request: ChargeRequest
  ) async -> Result<PaymentResponse, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      charge(request) { result in
        continuation.resume(returning: result)
      }
    }
  }
}

// MARK: - Refund
public extension CardForm {
  func refund(
    _ request: RefundRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    tokenize { result in
      switch result {
      case let .success(paymentMethod):
        self.apiClient?.createRefund(
          token: paymentMethod.paymentToken,
          amount: request.amount,
          currency: request.currency,
          descriptor: request.descriptor,
          idempotencyKey: request.idempotencyKey,
          metadata: request.metadata,
          completion: { result in
            completion?(
              result.map {
                .init(
                  id: $0.id,
                  paymentToken: paymentMethod.paymentToken,
                  details: .init(
                    amount: $0.amount,
                    authCode: $0.authCode,
                    batchId: $0.batchID,
                    cardBrand: $0.paymentNetwork,
                    lastFour: $0.lastFour,
                    status: $0.status,
                    statusCode: $0.statusCode,
                    statusDescription: $0.statusDescription,
                    surchargeFeeAmount: .none,
                    transactionDate: $0.transactionDate
                  )
                )
              }
            )
          }
        )
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  func refund(
    _ request: RefundRequest
  ) async -> Result<PaymentResponse, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      refund(request) { result in
        continuation.resume(returning: result)
      }
    }
  }
}

// MARK: - Internal
// MARK: APIClient instance
extension CardForm {
  static var apiClientAssociationKey: Void?

  var apiClient: APIClient? {
    get {
      objc_getAssociatedObject(
        self,
        &Self.apiClientAssociationKey
      ) as? APIClient
    }
    set {
      objc_setAssociatedObject(
        self,
        &Self.apiClientAssociationKey,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
}

// MARK: - SingleLineCardForm ViewModel
extension CardForm {
  var viewModel: CardFormViewModel? {
    class_getInstanceVariable(
      type(of: self),
      "_viewModel"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? CardFormViewModel
    }
  }
}

// MARK: - Private
private extension CardForm {
  var expDate: ExpirationDate? {
    let expirationMonth = viewModel?.expirationMonth.flatMap { UInt($0) }
    let expirationYear = viewModel?.expirationYear.flatMap { UInt($0) }
    if let expirationMonth, let expirationYear {
      return .init(month: expirationMonth, year: expirationYear)
    } else {
      return nil
    }
  }
}
