// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Address
public struct Address: APICodable, APIReqParameterable {
  public let line1: String?
  public let line2: String?
  public let country: String?
  public let state: String?
  public let city: String?
  public let postalCode: String?

  public init(
    line1: String?,
    line2: String?,
    country: String?,
    state: String?,
    city: String?,
    postalCode: String?
  ) {
    self.line1 = line1
    self.line2 = line2
    self.country = country
    self.state = state
    self.city = city
    self.postalCode = postalCode
  }
}
