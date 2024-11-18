// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum SeamlessPayError: LocalizedError {
  case requestCreationError(Error)
  case sessionTaskError(Error)
  case apiError(APIError)
  case responseSerializationError
  case unknown

  public var errorDescription: String? {
    switch self {
    case let .requestCreationError(error),
         let .sessionTaskError(error):
      return error.localizedDescription
    case let .apiError(error):
      return error.localizedDescription
    case .responseSerializationError:
      return "Response Serialization Error"
    case .unknown:
      return "Unknown Error"
    }
  }
}

extension SeamlessPayError {
  static func fromFailedSessionTask(data: Data?, error: Error?) -> Self {
    if let error {
      return .sessionTaskError(error)
    } else if let data {
      return .apiError(.init(data: data))
    } else {
      return .unknown
    }
  }
}

public struct SeamlessPayInvalidURLError: LocalizedError {
  public var errorDescription: String? {
    "Invalid URL"
  }
}
