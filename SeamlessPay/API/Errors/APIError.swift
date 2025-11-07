// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct APIError: Error, APIDecodable {
  public enum ErrorKind {
    case badRequest
    case unauthorized
    case declined
    case forbidden
    case unprocessable
    case rateLimit
    case `internal`
    case unavailable
    case unknown
  }

  public struct ErrorDetail: APIDecodable {
    public let message: String
    public let fieldName: String?
  }

  public let kind: ErrorKind
  public let statusCode: String?
  public let statusDescription: String?
  public let errors: [ErrorDetail]?
}

extension APIError {
  static var unknown: Self {
    .init(
      kind: .unknown,
      statusCode: .none,
      statusDescription: .none,
      errors: .none
    )
  }
}

// MARK: - Decodable
public extension APIError {
  private enum RootCodingKeys: String, CodingKey {
    case code
    case data
  }

  private enum DataCodingKeys: String, CodingKey {
    case statusCode
    case statusDescription
    case errors
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootCodingKeys.self)
    let code = try container.decodeIfPresent(Int.self, forKey: .code)

    let dataContainer = try container.nestedContainer(
      keyedBy: DataCodingKeys.self,
      forKey: .data
    )

    statusCode = try dataContainer.decodeIfPresent(
      String.self,
      forKey: .statusCode
    )
    statusDescription = try dataContainer.decodeIfPresent(
      String.self,
      forKey: .statusDescription
    )
    errors = try dataContainer.decodeIfPresent(
      [ErrorDetail].self,
      forKey: .errors
    )

    kind = APIError.mapKind(from: code)
  }

  private static func mapKind(from code: Int?) -> ErrorKind {
    switch code {
    case 400: return .badRequest
    case 401: return .unauthorized
    case 402: return .declined
    case 403: return .forbidden
    case 422: return .unprocessable
    case 429: return .rateLimit
    case 500: return .internal
    case 503: return .unavailable
    default: return .unknown
    }
  }
}
