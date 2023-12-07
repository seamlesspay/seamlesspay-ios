// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Event
public struct Event: Codable {
  public enum Status: String, APICodable {
    case success
    case fail
  }

  public enum EType: String, APICodable {
    case authorized
    case captured
    case declined
    case error
  }

  public let delta: String?
  public let createdAt: String?
  public let eventDelta: String?
  public let offlineCreatedAt: String?
  public let status: Event.Status?
  public let statusCode: String?
  public let statusDescription: String?
  public let type: EType?

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
