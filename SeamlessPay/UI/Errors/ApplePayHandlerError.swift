// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum ApplePayHandlerError: LocalizedError {
  case seamlessPayError(SeamlessPayError) // Errors returned by SeamlessPay
  case missingMerchantIdentifier
  case paymentProcessingInProgress

  public var errorDescription: String? {
    switch self {
    case let .seamlessPayError(error):
      return error.errorDescription
    case let .missingMerchantIdentifier:
      return "Missing merchant identifier"
    case .paymentProcessingInProgress:
      return "Payment processing is in progress"
    }
  }
}
