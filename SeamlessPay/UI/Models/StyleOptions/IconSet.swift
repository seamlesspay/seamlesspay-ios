// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - IconSet
public enum IconSet: Equatable {
  case light
  case dark
}

// MARK: - IconSet Extension
public extension IconSet? {
  func iconSet(for traitCollection: UITraitCollection) -> IconSet {
    if let iconSet = self {
      return iconSet
    }
    return traitCollection.userInterfaceStyle == .dark ? .dark : .light
  }
}
