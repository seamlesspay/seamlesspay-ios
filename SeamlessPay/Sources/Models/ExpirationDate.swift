// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct ExpirationDate {
  public let month: UInt
  public let year: UInt

  public init(month: UInt, year: UInt) {
    self.month = month
    self.year = year
  }

  public var stringValue: String {
    "\(month)/\(year)"
  }
}
