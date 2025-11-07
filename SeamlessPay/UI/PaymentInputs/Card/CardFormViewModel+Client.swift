// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - API Client Calls
extension CardFormViewModel {
  // MARK: Tokenize
  func tokenize(
    completion: ((Result<TokenizeResponse, APIError>) -> Void)?
  ) {
    apiClient?.tokenize(
      paymentType: .creditCard,
      accountNumber: cardNumber ?? .init(),
      expDate: expDate,
      cvv: cvc,
      accountType: .none,
      routing: .none,
      pin: .none,
      billingAddress: .init(
        line1: .none,
        line2: .none,
        country: .none,
        state: .none,
        city: .none,
        postalCode: postalCode
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
                paymentNetwork: $0.paymentNetwork,
                avsPostalCodeResult: $0.verificationResults?.avsPostalCode,
                avsStreetAddressResult: $0.verificationResults?.avsStreetAddress,
                cvvResult: $0.verificationResults?.cvv
              )
            )
          }
        )
      }
    )
  }

  func tokenize() async -> Result<TokenizeResponse, APIError> {
    await withCheckedContinuation { continuation in
      tokenize { result in
        continuation.resume(returning: result)
      }
    }
  }

  // MARK: Charge
  func charge(
    _ request: ChargeRequest,
    completion: ((Result<PaymentResponse, APIError>) -> Void)?
  ) {
    tokenize { result in
      switch result {
      case let .success(paymentMethod):
        self.apiClient?.createCharge(
          token: paymentMethod.paymentToken,
          amount: request.amount,
          cvv: self.cvc,
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
                    accountType: $0.accountType,
                    amount: $0.amount,
                    authCode: $0.authCode,
                    batchId: $0.batch,
                    cardBrand: $0.paymentNetwork,
                    currency: $0.currency,
                    expDate: $0.expDate,
                    lastFour: $0.lastFour,
                    status: $0.status,
                    statusCode: $0.statusCode,
                    statusDescription: $0.statusDescription,
                    surchargeFeeAmount: $0.surchargeFeeAmount,
                    tip: $0.tip,
                    transactionDate: $0.transactionDate,
                    avsPostalCodeResult: $0.verificationResults?.avsPostalCode,
                    avsStreetAddressResult: $0.verificationResults?.avsStreetAddress,
                    cvvResult: $0.verificationResults?.cvv
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
  ) async -> Result<PaymentResponse, APIError> {
    await withCheckedContinuation { continuation in
      charge(request) { result in
        continuation.resume(returning: result)
      }
    }
  }

  // MARK: Refund
  func refund(
    _ request: RefundRequest,
    completion: ((Result<PaymentResponse, APIError>) -> Void)?
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
                    accountType: $0.accountType,
                    amount: $0.amount,
                    authCode: $0.authCode,
                    batchId: $0.batchID,
                    cardBrand: $0.paymentNetwork,
                    currency: $0.currency,
                    expDate: .none,
                    lastFour: $0.lastFour,
                    status: $0.status,
                    statusCode: $0.statusCode,
                    statusDescription: $0.statusDescription,
                    surchargeFeeAmount: .none,
                    tip: .none,
                    transactionDate: $0.transactionDate,
                    avsPostalCodeResult: .none,
                    avsStreetAddressResult: .none,
                    cvvResult: .none
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
  ) async -> Result<PaymentResponse, APIError> {
    await withCheckedContinuation { continuation in
      refund(request) { result in
        continuation.resume(returning: result)
      }
    }
  }
}

// MARK: - APIClient instance
extension CardFormViewModel {
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

// MARK: - Private
private extension CardFormViewModel {
  var expDate: ExpirationDate? {
    let expirationMonth = expirationMonth.flatMap { UInt($0) }
    let expirationYear = expirationYear.flatMap { UInt($0) }
    if let expirationMonth, let expirationYear {
      return .init(month: expirationMonth, year: expirationYear)
    } else {
      return nil
    }
  }
}
