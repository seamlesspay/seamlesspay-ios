// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public protocol APICodable: Codable {
  static func decode(_ data: Data) throws -> Self
  func encode() throws -> Data
}

public extension APICodable {
  static func decode(_ data: Data) throws -> Self {
    try APIResponseDecoder.decode(Self.self, from: data)
  }

  func encode() throws -> Data {
    try APIResponseEncoder.encode(self)
  }
}

public protocol APIReqParameterable: APICodable {
  func asParameter() -> [String: String]?
}

public extension APIReqParameterable {
  func asParameter() -> [String: String]? {
    if let data = try? encode() {
      return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
    }
    return nil
  }
}

public var APIResponseDecoder: JSONDecoder {
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

public var APIResponseEncoder: JSONEncoder {
  let encoder = JSONEncoder()
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions.insert(.withFractionalSeconds)

  encoder.dateEncodingStrategy = .custom {
    var container = $1.singleValueContainer()
    try container.encode(formatter.string(from: $0))
  }
  return encoder
}
