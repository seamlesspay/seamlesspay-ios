// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct FieldOptions {
  public let cvv: FieldConfiguration
  public let postalCode: FieldConfiguration

  public init(cvv: FieldConfiguration, postalCode: FieldConfiguration) {
    self.cvv = cvv
    self.postalCode = postalCode
  }

  public static var `default`: Self {
    Self(cvv: .init(display: .required), postalCode: .init(display: .required))
  }
}

public struct FieldConfiguration {
  public let display: DisplayConfiguration

  public init(display: DisplayConfiguration) {
    self.display = display
  }
}
