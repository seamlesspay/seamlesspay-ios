// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

extension APIClient {
  func createCharge(
    token: String,
    cvv: String? = .none,
    request: ChargeRequest,
    completion: ((Result<PaymentResponse, APIError>) -> Void)?
  ) {
    createCharge(
      token: token,
      amount: request.amount,
      cvv: cvv,
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
              paymentToken: token,
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
  }
}
