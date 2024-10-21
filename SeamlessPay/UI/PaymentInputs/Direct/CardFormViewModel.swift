// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

extension CardFormViewModel {
  func isFieldRequired(_ field: SPCardFieldType) -> Bool {
    switch field {
    case .expiration,
         .number:
      return true
    case .CVC:
      return cvcRequired
    case .postalCode:
      return postalCodeRequired
    }
  }

  func isFieldDisplayed(_ field: SPCardFieldType) -> Bool {
    switch field {
    case .expiration,
         .number:
      return true
    case .CVC:
      return cvcDisplayed
    case .postalCode:
      return postalCodeDisplayed
    }
  }
}
