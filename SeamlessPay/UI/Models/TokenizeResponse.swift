// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct TokenizeResponse {
  public enum Details: Equatable {
    case creditCard(
      name: String?,
      lastFour: String?,
      expirationDate: String?,
      paymentNetwork: PaymentNetwork?
    )
    case giftCard
    case ach
  }

  public let paymentToken: String
  public let details: TokenizeResponse.Details
}

extension TokenizeResponse: Identifiable, Equatable {
  // MARK: Identifiable
  public var id: String {
    paymentToken
  }

  // MARK: Equatable
  public static func == (lhs: TokenizeResponse, rhs: TokenizeResponse) -> Bool {
    return lhs.paymentToken == rhs.paymentToken
  }
}
