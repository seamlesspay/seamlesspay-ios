// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Tokenize
public extension SPPaymentCardTextField {
  func tokenize(completion: ((Result<TokenizeResponse, SeamlessPayError>) -> Void)?) {
    apiClient?.tokenize(
      paymentType: .creditCard,
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
              token: $0.token,
              name: $0.name,
              lastFour: $0.lastFour,
              expirationDate: $0.expDate,
              paymentNetwork: $0.paymentNetwork
            )
          }
        )
      }
    )
  }

  private var expDate: ExpirationDate? {
    let expirationMonth = viewModel?.expirationMonth.flatMap { UInt($0) }
    let expirationYear = viewModel?.expirationYear.flatMap { UInt($0) }
    if let expirationMonth, let expirationYear {
      return .init(month: expirationMonth, year: expirationYear)
    } else {
      return nil
    }
  }
}

// MARK: - Submit
public extension SPPaymentCardTextField {
  func submit(
    amount: String,
    capture: Bool = true,
    currency: String? = nil,
    description: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    metadata: String? = nil,
    order: [String: String]? = nil,
    orderID: String? = nil,
    poNumber: String? = nil,
    surchargeFeeAmount: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    tokenize { tokenizeResult in
      switch tokenizeResult {
      case let .success(tokenize):
        self.apiClient?.createCharge(
          token: tokenize.token,
          cvv: self.viewModel?.cvc,
          capture: capture,
          currency: currency,
          amount: amount,
          taxAmount: taxAmount,
          taxExempt: taxExempt,
          tip: tip,
          surchargeFeeAmount: surchargeFeeAmount,
          description: description,
          order: order,
          orderID: orderID,
          poNumber: poNumber,
          metadata: metadata,
          descriptor: descriptor,
          entryType: entryType,
          idempotencyKey: idempotencyKey,
          completion: { result in
            completion?(
              result.map {
                PaymentResponse(
                  accountType: $0.accountType,
                  amount: $0.amount,
                  currency: $0.currency,
                  authCode: $0.authCode,
                  batchId: $0.batch,
                  expDate: $0.expDate,
                  id: $0.id,
                  lastFour: $0.lastFour,
                  cardBrand: .none,
                  status: $0.status,
                  statusCode: $0.statusCode,
                  statusDescription: $0.statusDescription,
                  surchargeFeeAmount: $0.surchargeFeeAmount,
                  tip: $0.tip,
                  transactionDate: $0.transactionDate
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

// MARK: - SPPaymentCardTextField ViewModel
private extension SPPaymentCardTextField {
  var viewModel: SPPaymentCardTextFieldViewModel? {
    if let ivar = class_getInstanceVariable(type(of: self), "_viewModel") {
      return object_getIvar(self, ivar) as? SPPaymentCardTextFieldViewModel
    }
    return nil
  }
}
