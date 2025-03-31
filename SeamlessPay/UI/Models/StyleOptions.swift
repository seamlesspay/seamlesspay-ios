// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

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
    StyleOptions(colors: .default, shapes: .default, typography: .default, iconSet: .none)
  }
}

// MARK: - Colors
public struct Colors: Equatable {
  public let light: ColorPalette
  public let dark: ColorPalette

  public init(light: ColorPalette, dark: ColorPalette) {
    self.light = light
    self.dark = dark
  }

  public static var `default`: Colors {
    Colors(light: .init(theme: .light), dark: .init(theme: .dark))
  }

  public func palette(for traitCollection: UITraitCollection) -> ColorPalette {
    return traitCollection.userInterfaceStyle == .dark ? dark : light
  }
}

// MARK: - ColorPalette
public struct ColorPalette: Equatable {
  public let theme: ThemeColors
  public let fieldColors: FieldColors?
  public let errorMessage: UIColor?
  public let header: UIColor?

  public init(
    theme: ThemeColors,
    fieldColors: FieldColors? = .none,
    errorMessage: UIColor? = .none,
    header: UIColor? = .none
  ) {
    self.theme = theme
    self.fieldColors = fieldColors
    self.errorMessage = errorMessage
    self.header = header
  }

  public static var `default`: ColorPalette {
    ColorPalette(theme: .default, fieldColors: .none)
  }
}

// MARK: - Field Colors
public extension ColorPalette {
  var fieldBackgroundInactiveColor: UIColor {
    fieldColors?.background?.inactive ?? .clear
  }

  var fieldBackgroundFocusValidColor: UIColor {
    fieldColors?.background?.focusValid ?? .clear
  }

  var fieldBackgroundFocusInvalidColor: UIColor {
    fieldColors?.background?.focusInvalid ?? .clear
  }

  var fieldBackgroundInvalidColor: UIColor {
    fieldColors?.background?.invalid ?? theme.danger.withAlphaComponent(0.1)
  }

  // NOTE: hint colors currently not used because of absence of hint label
  var fieldHintFocusValidColor: UIColor {
    fieldColors?.hint?.focusValid ?? theme.neutral.withAlphaComponent(0.25)
  }

  var fieldHintFocusInvalidColor: UIColor {
    fieldColors?.hint?.focusInvalid ?? theme.neutral.withAlphaComponent(0.25)
  }

  var fieldIconInactiveColor: UIColor {
    fieldColors?.icon?.inactive ?? theme.neutral.withAlphaComponent(0.25)
  }

  var fieldIconFocusValidColor: UIColor {
    fieldColors?.icon?.focusValid ?? theme.primary
  }

  var fieldIconFocusInvalidColor: UIColor {
    fieldColors?.icon?.focusInvalid ?? theme.danger
  }

  var fieldIconInvalidColor: UIColor {
    fieldColors?.icon?.invalid ?? theme.danger
  }

  var fieldLabelInactiveColor: UIColor {
    fieldColors?.label?.inactive ?? theme.neutral.withAlphaComponent(0.75)
  }

  var fieldLabelFocusValidColor: UIColor {
    fieldColors?.label?.focusValid ?? theme.primary
  }

  var fieldLabelFocusInvalidColor: UIColor {
    fieldColors?.label?.focusInvalid ?? theme.danger
  }

  var fieldLabelInvalidColor: UIColor {
    fieldColors?.label?.invalid ?? theme.danger
  }

  var fieldOutlineInactiveColor: UIColor {
    fieldColors?.outline?.inactive ?? theme.neutral.withAlphaComponent(0.25)
  }

  var fieldOutlineInvalidColor: UIColor {
    fieldColors?.outline?.invalid ?? theme.danger
  }

  var fieldOutlineFocusValidColor: UIColor {
    fieldColors?.outline?.focusValid ?? theme.primary
  }

  var fieldOutlineFocusInvalidColor: UIColor {
    fieldColors?.outline?.focusInvalid ?? theme.danger
  }

  var fieldTextFocusValidColor: UIColor {
    fieldColors?.text?.focusValid ?? theme.neutral
  }

  var fieldTextFocusInvalidColor: UIColor {
    fieldColors?.text?.focusInvalid ?? theme.danger
  }

  var fieldTextInvalidColor: UIColor {
    fieldColors?.text?.invalid ?? theme.danger
  }

  var fieldTextInactiveColor: UIColor {
    fieldColors?.text?.inactive ?? theme.neutral
  }

  var errorMessageColor: UIColor {
    errorMessage ?? theme.danger
  }

  var headerColor: UIColor {
    header ?? theme.neutral.withAlphaComponent(0.75)
  }
}

// MARK: - ThemeColors
public struct ThemeColors: Equatable {
  public let neutral: UIColor
  public let primary: UIColor
  public let danger: UIColor

  public init(neutral: UIColor, primary: UIColor, danger: UIColor) {
    self.neutral = neutral
    self.primary = primary
    self.danger = danger
  }

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
      neutral: UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1),
      primary: UIColor(red: 137 / 255, green: 180 / 255, blue: 255 / 255, alpha: 1),
      danger: UIColor(red: 255 / 255, green: 94 / 255, blue: 105 / 255, alpha: 1)
    )
  }
}

// MARK: - Shapes
public struct Shapes: Equatable {
  public let cornerRadius: CGFloat

  public init(cornerRadius: CGFloat) {
    self.cornerRadius = cornerRadius
  }

  public static var `default`: Shapes {
    Shapes(cornerRadius: 4.0)
  }
}

// MARK: - Shadow
public struct Shadow: Equatable {
  public let elevation: ElevationLevel

  public init(elevation: ElevationLevel) {
    self.elevation = elevation
  }

  public static var `default`: Shadow {
    Shadow(elevation: .none)
  }
}

// MARK: - ElevationLevel
public enum ElevationLevel: Equatable {
  case none
  case level1
  case level2
  case level3
  case level4
  case level5
}

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
    Typography(font: UIFont.systemFont(ofSize: 16, weight: .regular), scale: 1.0)
  }

  public var scaledFont: UIFont {
    scaledFont(for: font)
  }

  public func scaledFont(for font: UIFont) -> UIFont {
    let customFont = font.withSize(font.pointSize * scale)
    return UIFontMetrics.default.scaledFont(for: customFont)
  }
}

// MARK: - IconSet
public enum IconSet: Equatable {
  case light
  case dark
}

// MARK: - IconSet Extension
public extension Optional where Wrapped == IconSet {
  func iconSet(for traitCollection: UITraitCollection) -> IconSet {
    if let iconSet = self {
      return iconSet
    }
    return traitCollection.userInterfaceStyle == .dark ? .dark : .light
  }
}

// MARK: - FieldColors
public struct FieldColors: Equatable {
  public let background: FieldColor?
  public let hint: FieldColor?
  public let icon: FieldColor?
  public let label: FieldColor?
  public let outline: FieldColor?
  public let text: FieldColor?

  public init(
    background: FieldColor?,
    hint: FieldColor?,
    icon: FieldColor?,
    label: FieldColor?,
    outline: FieldColor?,
    text: FieldColor?
  ) {
    self.background = background
    self.hint = hint
    self.icon = icon
    self.label = label
    self.outline = outline
    self.text = text
  }
}

// MARK: - FieldColor
public struct FieldColor: Equatable {
  public let inactive: UIColor
  public let focusValid: UIColor
  public let focusInvalid: UIColor
  public let invalid: UIColor

  public init(inactive: UIColor, focusValid: UIColor, focusInvalid: UIColor, invalid: UIColor) {
    self.inactive = inactive
    self.focusValid = focusValid
    self.focusInvalid = focusInvalid
    self.invalid = invalid
  }
}
