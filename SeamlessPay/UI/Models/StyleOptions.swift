// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

public struct StyleOptions {
  public var colors: Colors = .default
  public var shapes: Shapes = .default
  public var typography: Typography = .default

  public static var `default`: StyleOptions {
    StyleOptions(colors: .default, shapes: .default, typography: .default)
  }
}

public struct Colors {
  public var light: ColorPalette
  public var dark: ColorPalette

  public static var `default`: Colors {
    Colors(light: .init(theme: .light), dark: .init(theme: .dark))
  }

  public func palette(for traitCollection: UITraitCollection) -> ColorPalette {
    return traitCollection.userInterfaceStyle == .dark ? dark : light
  }
}

public struct ColorPalette {
  public var theme: ThemeColors

  public static var `default`: ColorPalette {
    ColorPalette(theme: .default)
  }
}

public struct ThemeColors {
  public var neutral: UIColor
  public var primary: UIColor
  public var danger: UIColor

  public static var `default`: ThemeColors {
    .light
  }

  public static var light: ThemeColors {
    ThemeColors(
      neutral: UIColor(red: 42 / 255, green: 42 / 255, blue: 42 / 255, alpha: 1),
      primary: UIColor(red: 59 / 255, green: 130 / 255, blue: 246 / 255, alpha: 1),
      danger: UIColor(red: 186 / 255, green: 32 / 255, blue: 60 / 255, alpha: 1)
    )
  }

  public static var dark: ThemeColors {
    ThemeColors(
      neutral: UIColor(red: 249 / 255, green: 249 / 255, blue: 249 / 255, alpha: 1),
      primary: UIColor(red: 59 / 255, green: 130 / 255, blue: 246 / 255, alpha: 1),
      danger: UIColor(red: 207 / 255, green: 102 / 255, blue: 121 / 255, alpha: 1)
    )
  }
}

public struct Shapes {
  public var cornerRadius: CGFloat

  public static var `default`: Shapes {
    Shapes(cornerRadius: 8.0)
  }
}

public struct Shadow {
  public var elevation: ElevationLevel

  public static var `default`: Shadow {
    Shadow(elevation: .none)
  }
}

public enum ElevationLevel {
  case none
  case level1
  case level2
  case level3
  case level4
  case level5
}

public struct Typography {
  public var font: UIFont
  public var scale: CGFloat {
    willSet {
      if newValue <= 0.0 {
        assertionFailure("scale must be a value greater than zero")
      }
    }
  }

  public static var `default`: Typography {
    Typography(font: UIFont.systemFont(ofSize: 18), scale: 1.0)
  }

  public var scaledFont: UIFont {
    scaledFont(for: font)
  }

  public func scaledFont(for font: UIFont) -> UIFont {
    let customFont = font.withSize(font.pointSize * scale)
    return UIFontMetrics.default.scaledFont(for: customFont)
  }
}
