// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum SeamlessPayError: LocalizedError {
  case requestCreationError(Error)
  // TODO: Create separate type to represent api errors instead of SPError type
  case apiError(SPError)
  case responseSerializationError

  public var errorDescription: String? {
    switch self {
    case let .requestCreationError(error):
      return error.localizedDescription
    case let .apiError(error):
      return error.localizedDescription
    case .responseSerializationError:
      return "Response Serialization Error"
    }
  }
}

public struct SeamlessPayInvalidURLError: LocalizedError {
  public var errorDescription: String? {
    "Invalid URL"
  }
}

// MARK: SeamlessPayError + SPError
public extension SeamlessPayError {
  var spError: SPError {
    switch self {
    case let .apiError(error):
      return error
    case .requestCreationError,
         .responseSerializationError:
      return SPError.sdkError(description: localizedDescription)
    }
  }
}

public extension SPError {
  static func sdkError(description: String) -> SPError {
    SPError(
      domain: "ios.sdk.seamlesspay.com",
      code: 0,
      userInfo: [
        NSLocalizedDescriptionKey: description,
      ]
    )
  }
}
