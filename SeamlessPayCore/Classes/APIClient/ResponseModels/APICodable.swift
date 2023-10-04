// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

protocol APICodable: Codable {
  static func decode(_ data: Data) throws -> Self
}

extension APICodable {
  static func decode(_ data: Data) throws -> Self {
    try APIResponseDecoder.decode(Self.self, from: data)
  }

}

private var APIResponseDecoder: JSONDecoder {
  let decoder = JSONDecoder()
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions.insert(.withFractionalSeconds)

  decoder.dateDecodingStrategy = .custom {
    let container = try $0.singleValueContainer()
    let string = try container.decode(String.self)
    if let date = formatter.date(from: string) {
      return date
    }
    throw DecodingError.dataCorruptedError(
      in: container,
      debugDescription: "Invalid date: \(string)"
    )
  }

  return decoder
}

private var APIResponseEncoder: JSONEncoder {
  let encoder = JSONEncoder()
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions.insert(.withFractionalSeconds)

  encoder.dateEncodingStrategy = .custom {
    var container = $1.singleValueContainer()
    try container.encode(formatter.string(from: $0))
  }
  return encoder
}