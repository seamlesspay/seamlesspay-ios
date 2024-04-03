// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct PaymentMethodResponse: Identifiable, Equatable {
  public struct Details: Equatable {
    public let name: String?
    public let lastFour: String?
    public let expirationDate: String?
    public let paymentNetwork: PaymentNetwork?
  }

  public let paymentToken: String
  public let paymentType: PaymentType
  public let details: Details

  // MARK: Identifiable
  public var id: String {
    paymentToken
  }
}
