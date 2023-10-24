// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Address compatibility
public extension SPAddress {
  convenience init(address: SPAddress) {
    self.init()

    city = address.city
    country = address.country
    line1 = address.line1
    line2 = address.line2
    postalCode = address.postalCode
    state = address.state
  }
}
