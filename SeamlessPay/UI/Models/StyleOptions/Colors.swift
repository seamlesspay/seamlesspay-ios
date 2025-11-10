// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Colors
public struct Colors: Equatable {
  public let light: ColorPalette
  public let dark: ColorPalette

  public init(light: ColorPalette, dark: ColorPalette) {
    self.light = light
    self.dark = dark
  }

  public static var `default`: Colors {
    .init(light: .init(theme: .light), dark: .init(theme: .dark))
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
    .init(theme: .default, fieldColors: .none)
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
    .init(
      neutral: .init(red255: 42, green255: 42, blue255: 42),
      primary: .init(red255: 37, green255: 99, blue255: 235),
      danger: .init(red255: 186, green255: 32, blue255: 60)
    )
  }

  public static var dark: ThemeColors {
    .init(
      neutral: .init(red255: 245, green255: 245, blue255: 245),
      primary: .init(red255: 90, green255: 151, blue255: 242),
      danger: .init(red255: 255, green255: 94, blue255: 105)
    )
  }
}

// MARK: - UIColor Extension
private extension UIColor {
  convenience init(
    red255 red: CGFloat,
    green255 green: CGFloat,
    blue255 blue: CGFloat,
    alpha: CGFloat = 1
  ) {
    self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
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
