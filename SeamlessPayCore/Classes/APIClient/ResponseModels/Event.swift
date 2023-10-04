// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Event
@objcMembers
@objc(SPEvent) public class Event: NSObject, Codable {
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

  public init(
    delta: String?,
    createdAt: String?,
    eventDelta: String?,
    offlineCreatedAt: String?,
    status: String?,
    statusCode: String?,
    statusDescription: String?,
    type: String?
  ) {
    self.delta = delta
    self.createdAt = createdAt
    self.eventDelta = eventDelta
    self.offlineCreatedAt = offlineCreatedAt
    self.status = status
    self.statusCode = statusCode
    self.statusDescription = statusDescription
    self.type = type
  }
}
