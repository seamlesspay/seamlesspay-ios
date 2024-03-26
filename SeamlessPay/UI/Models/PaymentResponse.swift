// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct PaymentResponse {
  let accountType: AccountType?
  let amount: String?
  let currency: Currency?
  let authCode: String?
  let batchId: String?
  let expDate: String?
  let id: String
  let lastFour: String?
  let cardBrand: String?
  let status: TransactionStatus?
  let statusCode: String?
  let statusDescription: String?
  let surchargeFeeAmount: String?
  let tip: String?
  let transactionDate: String?
}
