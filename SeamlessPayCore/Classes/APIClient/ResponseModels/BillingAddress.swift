// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - BillingAddress
public struct BillingAddress: Codable {
  public let city: String?
  public let country: String?
  public let line1: String?
  public let line2: String?
  public let postalCode: String?
  public let state: String?
}
