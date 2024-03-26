// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct TokenizeResponse {
  let token: String
  let name: String?
  let lastFour: String?
  let expirationDate: String?
  let paymentNetwork: PaymentNetwork?
}
