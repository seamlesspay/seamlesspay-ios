// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Public
// MARK: Init with Authorization model
public extension SingleLineCardForm {
  convenience init(authorization: Authorization, fieldOptions: FieldOptions = .default) {
    self.init()
    setAuthorization(authorization)
    setFieldOptions(fieldOptions)
  }

  func setAuthorization(
    _ authorization: Authorization
  ) {
    apiClient = .init(authorization: authorization)
  }

  func setFieldOptions(_ fieldOptions: FieldOptions) {
    viewModel?.cvcDisplayed = fieldOptions.cvv.display != .none
    viewModel?.cvcRequired = fieldOptions.cvv.display == .required

    viewModel?.postalCodeDisplayed = fieldOptions.postalCode.display != .none
    viewModel?.postalCodeRequired = fieldOptions.postalCode.display == .required
  }
}

// MARK: Tokenize
public extension SingleLineCardForm {
  func tokenize(
    completion: ((Result<PaymentMethodResponse, SeamlessPayError>) -> Void)?
  ) {
    let paymentType: PaymentType = .creditCard
    apiClient?.tokenize(
      paymentType: paymentType,
      accountNumber: viewModel?.cardNumber ?? .init(),
      expDate: expDate,
      cvv: viewModel?.cvc,
      accountType: .none,
      routing: .none,
      pin: .none,
      billingAddress: .none,
      name: .none,
      completion: { result in
        completion?(
          result.map {
            .init(
              paymentToken: $0.token,
              paymentType: paymentType,
              details: .init(
                name: $0.name,
                lastFour: $0.lastFour,
                expirationDate: $0.expDate,
                paymentNetwork: $0.paymentNetwork
              )
            )
          }
        )
      }
    )
  }
}

// MARK: - Submit
public extension SingleLineCardForm {
  func submit(
    _ request: PaymentRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    tokenize { result in
      switch result {
      case let .success(paymentMethod):
        self.apiClient?.createCharge(
          token: paymentMethod.paymentToken,
          cvv: self.viewModel?.cvc,
          capture: request.capture,
          currency: request.currency,
          amount: request.amount,
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
                  paymentMethod: paymentMethod,
                  details: .init(
                    accountType: $0.accountType,
                    amount: $0.amount,
                    currency: $0.currency,
                    authCode: $0.authCode,
                    batchId: $0.batch,
                    expDate: $0.expDate,
                    lastFour: $0.lastFour,
                    cardBrand: paymentMethod.details.paymentNetwork,
                    status: $0.status,
                    statusCode: $0.statusCode,
                    statusDescription: $0.statusDescription,
                    surchargeFeeAmount: $0.surchargeFeeAmount,
                    tip: $0.tip,
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
}

// MARK: - Internal
// MARK: APIClient instance
extension SingleLineCardForm {
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
private extension SingleLineCardForm {
  var viewModel: SingleLineCardFormViewModel? {
    class_getInstanceVariable(
      type(of: self),
      "_viewModel"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? SingleLineCardFormViewModel
    }
  }
}

// MARK: - Private
private extension SingleLineCardForm {
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