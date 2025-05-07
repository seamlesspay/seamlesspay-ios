// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct DigitalWallet: APICodable, APIReqParameterable {
  public let merchantId: String?
  public let token: Token
  public let type: String

  public init(merchantId: String?, token: Token) {
    self.merchantId = merchantId
    self.token = token
    self.type = "apple_pay"
  }

  public struct Token: APICodable {
    public let paymentData: PaymentData?
    public let paymentMethod: PaymentMethod
    public let transactionIdentifier: String

    public struct PaymentData: APICodable {
      public let data: String
      public let signature: String
      public let header: Header
      public let version: String

      public struct Header: APICodable {
        public let publicKeyHash: String
        public let ephemeralPublicKey: String
        public let transactionId: String
      }
    }

    public struct PaymentMethod: APICodable {
      public let displayName: String?
      public let network: String?
      public let type: String
    }
  }
}
