// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

extension NSDecimalNumber {
  static func fromUnits(_ value: Int) -> NSDecimalNumber {
    let decimalValue = Self(value: value)
    return decimalValue.dividing(by: Self(value: 100))
  }
}
