// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct RefundResponse: Identifiable, Equatable {
  public struct Details: Equatable {
    public let amount: String?
    public let authCode: String?
    public let batchId: String?
    public let lastFour: String?
    public let cardBrand: PaymentNetwork?
    public let status: TransactionStatus?
    public let statusCode: String?
    public let statusDescription: String?
    public let transactionDate: String?
  }

  public let id: String
  public let paymentMethod: PaymentMethodResponse
  public let details: Details
}
