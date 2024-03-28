// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct TokenizeResponse {
  public let token: String
  public let name: String?
  public let lastFour: String?
  public let expirationDate: String?
  public let paymentNetwork: PaymentNetwork?
}
