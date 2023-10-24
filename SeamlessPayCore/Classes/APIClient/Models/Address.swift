// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Address
public struct Address {
  public let city: String?
  public let country: String?
  public let line1: String?
  public let line2: String?
  public let postalCode: String?
  public let state: String?

  public init(
    line1: String?,
    line2: String?,
    city: String?,
    country: String?,
    state: String?,
    postalCode: String?
  ) {
    self.city = city
    self.country = country
    self.line1 = line1
    self.line2 = line2
    self.postalCode = postalCode
    self.state = state
  }
}

extension Address: APIEncodable, APIReqParameterable {}

// MARK: - SPAddress compatibility
public extension Address {
  init(spAddress: SPAddress) {
    city = spAddress.city
    country = spAddress.country
    line1 = spAddress.line1
    line2 = spAddress.line2
    postalCode = spAddress.postalCode
    state = spAddress.state
  }
}
