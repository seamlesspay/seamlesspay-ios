// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - PageOfCharges
public class ChargePage: NSObject, APIPaginable, APICodable {
  public let data: [Charge]
  public let pagination: Pagination
  public let total: Int

  public init(data: [Charge], pagination: Pagination, total: Int) {
    self.data = data
    self.pagination = pagination
    self.total = total
  }
}
