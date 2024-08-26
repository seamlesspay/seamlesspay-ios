// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct ChargeRequest {
  public let amount: Int
  public let capture: Bool
  public let currency: String?
  public let description: String?
  public let descriptor: String?
  public let entryType: String?
  public let idempotencyKey: String?
  public let metadata: String?
  public let order: [String: String]?
  public let orderID: String?
  public let poNumber: String?
  public let surchargeFeeAmount: Int?
  public let taxAmount: Int?
  public let taxExempt: Bool?
  public let tip: Int?

  public init(
    amount: Int,
    capture: Bool = true,
    currency: String? = .none,
    description: String? = .none,
    descriptor: String? = .none,
    entryType: String? = .none,
    idempotencyKey: String? = .none,
    metadata: String? = .none,
    order: [String: String]? = .none,
    orderID: String? = .none,
    poNumber: String? = .none,
    surchargeFeeAmount: Int? = .none,
    taxAmount: Int? = .none,
    taxExempt: Bool? = .none,
    tip: Int? = .none
  ) {
    self.amount = amount
    self.capture = capture
    self.currency = currency
    self.description = description
    self.descriptor = descriptor
    self.entryType = entryType
    self.idempotencyKey = idempotencyKey
    self.metadata = metadata
    self.order = order
    self.orderID = orderID
    self.poNumber = poNumber
    self.surchargeFeeAmount = surchargeFeeAmount
    self.taxAmount = taxAmount
    self.taxExempt = taxExempt
    self.tip = tip
  }
}
