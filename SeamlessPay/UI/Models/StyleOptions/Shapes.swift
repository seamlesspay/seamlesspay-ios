// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Shapes
public struct Shapes: Equatable {
  public let cornerRadius: CGFloat

  public init(cornerRadius: CGFloat) {
    self.cornerRadius = cornerRadius
  }

  public static var `default`: Shapes {
    .init(cornerRadius: 4.0)
  }
}
