// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - StyleOptions
public struct StyleOptions: Equatable {
  public let colors: Colors
  public let shapes: Shapes
  public let typography: Typography
  public let iconSet: IconSet?

  public init(colors: Colors, shapes: Shapes, typography: Typography, iconSet: IconSet?) {
    self.colors = colors
    self.shapes = shapes
    self.typography = typography
    self.iconSet = iconSet
  }

  public static var `default`: StyleOptions {
    .init(colors: .default, shapes: .default, typography: .default, iconSet: .none)
  }
}
