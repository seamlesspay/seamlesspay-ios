// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum PaymentType: String, APICodable {
  case creditCard = "credit_card"
  case plDebitCard = "pldebit_card"
  case giftCard = "gift_card"
  case ach
}
