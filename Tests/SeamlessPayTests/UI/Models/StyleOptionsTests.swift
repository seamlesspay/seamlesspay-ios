// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

class StyleOptionsTests: XCTestCase {
  func testIconSetForTraitCollectionWhenIconSetIsNilAndUserInterfaceStyleIsDark() {
    let traitCollection = UITraitCollection(userInterfaceStyle: .dark)
    let iconSet: IconSet? = nil

    let result = iconSet.iconSet(for: traitCollection)

    XCTAssertEqual(
      result,
      .dark,
      "Expected iconSet to be .dark when userInterfaceStyle is dark and iconSet is nil"
    )
  }

  func testIconSetForTraitCollectionWhenIconSetIsNilAndUserInterfaceStyleIsLight() {
    let traitCollection = UITraitCollection(userInterfaceStyle: .light)
    let iconSet: IconSet? = nil

    let result = iconSet.iconSet(for: traitCollection)

    XCTAssertEqual(
      result,
      .light,
      "Expected iconSet to be .light when userInterfaceStyle is light and iconSet is nil"
    )
  }

  func testIconSetForTraitCollectionWhenIconSetIsNotNil() {
    let traitCollection = UITraitCollection(userInterfaceStyle: .light)
    let iconSet: IconSet? = .dark

    let result = iconSet.iconSet(for: traitCollection)

    XCTAssertEqual(
      result,
      .dark,
      "Expected iconSet to return the actual value when it is not nil"
    )
  }

  func testPaletteForTraitCollectionWhenUserInterfaceStyleIsDark() {
    let traitCollection = UITraitCollection(userInterfaceStyle: .dark)
    let colors = Colors(light: .default, dark: .default)

    let result = colors.palette(for: traitCollection)

    XCTAssertEqual(
      result,
      colors.dark,
      "Expected palette to be dark when userInterfaceStyle is dark"
    )
  }

  func testPaletteForTraitCollectionWhenUserInterfaceStyleIsLight() {
    let traitCollection = UITraitCollection(userInterfaceStyle: .light)
    let colors = Colors(light: .default, dark: .default)

    let result = colors.palette(for: traitCollection)

    XCTAssertEqual(
      result,
      colors.light,
      "Expected palette to be light when userInterfaceStyle is light"
    )
  }
}
