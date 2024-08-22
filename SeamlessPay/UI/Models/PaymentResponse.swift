// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct PaymentResponse: Identifiable, Equatable {
  public struct Details: Equatable {
    public let accountType: AccountType?
    public let amount: Int?
    public let authCode: String?
    public let batchId: String?
    public let cardBrand: PaymentNetwork?
    public let currency: Currency?
    public let expDate: String?
    public let lastFour: String?
    public let status: TransactionStatus?
    public let statusCode: String?
    public let statusDescription: String?
    public let surchargeFeeAmount: Int?
    public let tip: String?
    public let transactionDate: String?
    public let avsPostalCodeResult: AVSResult?
    public let avsStreetAddressResult: AVSResult?
    public let cvvResult: AVSResult?
  }

  public let id: String
  public let paymentToken: String
  public let details: Details
}
