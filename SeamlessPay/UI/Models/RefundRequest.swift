// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct RefundRequest {
  public let amount: Int
  public let currency: String?
  public let descriptor: String?
  public let idempotencyKey: String?
  public let metadata: String?

  public init(
    amount: Int,
    currency: String? = .none,
    descriptor: String? = .none,
    idempotencyKey: String? = .none,
    metadata: String? = .none
  ) {
    self.amount = amount
    self.currency = currency
    self.descriptor = descriptor
    self.idempotencyKey = idempotencyKey
    self.metadata = metadata
  }
}
