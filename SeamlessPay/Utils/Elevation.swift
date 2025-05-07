// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - ElevationData

private struct Elevation {
  let alpha: Float
  let offset: CGSize
  let blur: CGFloat // Radius
}

private extension Elevation {
  init(elevationLevel: ElevationLevel) {
    switch elevationLevel {
    case .none:
      self = Elevation(alpha: 0, offset: .zero, blur: 0)
    case .level1:
      self = Elevation(alpha: 0.2, offset: CGSize(width: 0, height: 2), blur: 4)
    case .level2:
      self = Elevation(alpha: 0.2, offset: CGSize(width: 0, height: 3), blur: 4)
    case .level3:
      self = Elevation(alpha: 0.15, offset: CGSize(width: 0, height: 4), blur: 10)
    case .level4:
      self = Elevation(alpha: 0.15, offset: CGSize(width: 0, height: 5), blur: 10)
    case .level5:
      self = Elevation(alpha: 0.12, offset: CGSize(width: 0, height: 6), blur: 12)
    }
  }
}

// MARK: - CALayer Extension

public extension CALayer {
  private static var baseShadowColor: UIColor {
    UIColor(red: 31 / 255, green: 40 / 255, blue: 51 / 255, alpha: 1)
  }

  // swiftlint:disable function_parameter_count
  private func setShadow(
    with color: UIColor?,
    radius: CGFloat,
    offset: CGSize,
    rect: CGRect,
    cornerRadius: CGFloat,
    opacity: Float
  ) {
//    shouldRasterize = true
//    rasterizationScale = UIScreen.main.scale
    shadowColor = color?.cgColor
    shadowOffset = offset
    shadowOpacity = opacity

    shadowRadius = radius / 2.0

    if rect.isEmpty == false {
      shadowPath = cornerRadius > 0 ?
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath :
        UIBezierPath(rect: rect).cgPath
    }
  }

  // swiftlint:enable function_parameter_count

  func setElevationLevel(_ level: ElevationLevel, rect: CGRect, cornerRadius: CGFloat) {
    let elevationData = Elevation(elevationLevel: level)

    setShadow(
      with: Self.baseShadowColor,
      radius: elevationData.blur,
      offset: elevationData.offset,
      rect: rect,
      cornerRadius: cornerRadius,
      opacity: elevationData.alpha
    )
  }
}
