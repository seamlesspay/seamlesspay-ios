// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct PaymentResponse {
  public enum Details {
    case creditCard(
      accountType: AccountType?,
      amount: String?,
      currency: Currency?,
      authCode: String?,
      batchId: String?,
      expDate: String?,
      lastFour: String?,
      cardBrand: PaymentNetwork?,
      status: TransactionStatus?,
      statusCode: String?,
      statusDescription: String?,
      surchargeFeeAmount: String?,
      tip: String?,
      transactionDate: String?
    )
    case giftCard
    case ach
  }

  public let paymentToken: String
  public let details: PaymentResponse.Details
}

extension PaymentResponse: Identifiable, Equatable {
  // MARK: Identifiable
  public var id: String {
    paymentToken
  }

  // MARK: Equatable
  public static func == (lhs: PaymentResponse, rhs: PaymentResponse) -> Bool {
    return lhs.paymentToken == rhs.paymentToken
  }
}
