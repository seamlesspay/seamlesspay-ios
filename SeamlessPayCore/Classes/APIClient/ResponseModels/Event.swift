// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Event
public struct Event: Codable {
  public let delta: String?
  public let createdAt: String?
  public let eventDelta: String?
  public let offlineCreatedAt: String?
  public let status: String?
  public let statusCode: String?
  public let statusDescription: String?
  public let type: String?

  enum CodingKeys: String, CodingKey {
    case delta = "_delta"
    case createdAt
    case eventDelta = "delta"
    case offlineCreatedAt
    case status
    case statusCode
    case statusDescription
    case type
  }
}
