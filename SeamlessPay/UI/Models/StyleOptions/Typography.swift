// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Typography
public struct Typography: Equatable {
  public let font: UIFont
  public var scale: CGFloat {
    willSet {
      if newValue <= 0.0 {
        assertionFailure("scale must be a value greater than zero")
      }
    }
  }

  public init(font: UIFont, scale: CGFloat) {
    self.font = font
    self.scale = scale
  }

  public static var `default`: Typography {
    .init(font: UIFont.systemFont(ofSize: 16, weight: .regular), scale: 1.0)
  }

  public var scaledFont: UIFont {
    scaledFont(for: font)
  }

  func scaledFont(for font: UIFont) -> UIFont {
    let customFont = font.withSize(font.pointSize * scale)
    return UIFontMetrics.default.scaledFont(for: customFont)
  }

  func modifiedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
    let descriptor = font.fontDescriptor.addingAttributes([.traits: traits])

    return .init(descriptor: descriptor, size: size)
  }
}
