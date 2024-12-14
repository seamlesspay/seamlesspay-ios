// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

extension CardFormViewModel {
  func isFieldRequired(_ fieldType: SPCardFieldType) -> Bool {
    switch fieldType {
    case .expiration,
         .number:
      return true
    case .CVC:
      return cvcRequired
    case .postalCode:
      return postalCodeRequired
    @unknown default:
      return false
    }
  }

  func isFieldDisplayed(_ fieldType: SPCardFieldType) -> Bool {
    switch fieldType {
    case .expiration,
         .number:
      return true
    case .CVC:
      return cvcDisplayed
    case .postalCode:
      return postalCodeDisplayed
    @unknown default:
      return true
    }
  }

  func valueForField(_ fieldType: SPCardFieldType) -> String? {
    switch fieldType {
    case .number:
      return cardNumber
    case .expiration:
      return rawExpiration
    case .CVC:
      return cvc
    case .postalCode:
      return postalCode
    @unknown default:
      return .none
    }
  }
}

extension CardFormViewModel {
  func formValidationForField(_ fieldType: SPCardFieldType) -> FormValidationError? {
    // Return early if field is not required
    guard isFieldRequired(fieldType) else {
      return nil
    }

    let validationState = validationState(for: fieldType)
    let isFieldEmpty = valueForField(fieldType)?.isEmpty ?? true

    return getValidationError(for: fieldType, state: validationState, isEmpty: isFieldEmpty)
  }

  func realTimeValidationForField(
    _ fieldType: SPCardFieldType,
    isFocused: Bool
  ) -> FormValidationError? {
    // Return early if field is not required
    guard isFieldRequired(fieldType) else {
      return .none
    }

    let validationState = validationState(for: fieldType)
    let isFieldEmpty = valueForField(fieldType)?.isEmpty ?? true

    // Return nil for incomplete empty fields
    if validationState == .incomplete {
      // Return nil for empty fields if not focused
      if isFocused {
        return .none
      }
      // Return nil for empty fields if not focused
      if isFieldEmpty {
        return .none
      }
    }

    return getValidationError(for: fieldType, state: validationState, isEmpty: isFieldEmpty)
  }

  private func getValidationError(
    for fieldType: SPCardFieldType,
    state: SPCardValidationState,
    isEmpty: Bool
  ) -> FormValidationError? {
    switch (fieldType, state, isEmpty) {
    // No error
    case (_, .valid, _):
      return .none
    // Number field errors
    case (.number, .incomplete, false),
         (.number, .invalid, _):
      return .numberInvalid
    case (.number, .incomplete, true):
      return .numberRequired
    // Expiration field errors
    case (.expiration, .invalid, _):
      return .expirationInvalidDate
    case (.expiration, .incomplete, true):
      return .expirationRequired
    case (.expiration, .incomplete, false):
      return .expirationInvalid
    // CVC field errors
    case (.CVC, .incomplete, true):
      return .cvcRequired
    case (.CVC, .incomplete, false),
         (.CVC, .invalid, _):
      return .cvcInvalid
    // Postal code field errors
    case (.postalCode, .incomplete, true):
      return .postalCodeRequired
    case (.postalCode, .incomplete, false),
         (.postalCode, .invalid, _):
      return .postalCodeInvalid
    default:
      return .none
    }
  }
}
