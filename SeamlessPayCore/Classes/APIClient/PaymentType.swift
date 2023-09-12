// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

@objc(SPPaymentType) public enum PaymentType: Int {
  case ach
  case creditCard
  case giftCard
  case plDebitCard
}

extension PaymentType {
  var name: String {
    switch self {
    case .ach:
      return "ach"
    case .creditCard:
      return "credit_card"
    case .giftCard:
      return "gift_card"
    case .plDebitCard:
      return "pldebit_card"
    @unknown default:
      return "unspecified"
    }
  }
}
