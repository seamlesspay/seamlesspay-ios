// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

enum CardFormError: LocalizedError {
  case clientError(SeamlessPayError)
  case numberRequired
  case numberInvalid
  case expirationRequired
  case expirationInvalid
  case expirationInvalidDate
  case cvcRequired
  case cvcInvalid
  case postalCodeRequired
  case postalCodeInvalid

  var errorDescription: String? {
    switch self {
    case let .clientError(error):
      return error.localizedDescription
    case .numberRequired:
      return "Card number is required"
    case .numberInvalid:
      return "Card number is invalid"
    case .expirationRequired:
      return "Expiration date is required"
    case .expirationInvalid:
      return "Expiration date is invalid"
    case .expirationInvalidDate:
      return "Expiration date is invalid"
    case .cvcRequired:
      return "CVC is required"
    case .cvcInvalid:
      return "CVC is invalid"
    case .postalCodeRequired:
      return "Postal code is required"
    case .postalCodeInvalid:
      return "Postal code is invalid"
    }
  }
}
