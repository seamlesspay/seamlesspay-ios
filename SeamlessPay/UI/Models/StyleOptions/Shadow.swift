// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - ElevationLevel
public enum ElevationLevel: Equatable {
  case none
  case level1
  case level2
  case level3
  case level4
  case level5
}

// MARK: - Shadow
public struct Shadow: Equatable {
  public let elevation: ElevationLevel

  public init(elevation: ElevationLevel) {
    self.elevation = elevation
  }

  public static var `default`: Shadow {
    .init(elevation: .none)
  }
}
