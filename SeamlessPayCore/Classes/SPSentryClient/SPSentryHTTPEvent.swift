// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK:  SPSentryHTTPEvent
struct SPSentryHTTPEvent: Codable {

  // MARK:  Contexts
  struct Contexts: Codable {
    // MARK:  Response
    struct Response: Codable {
      let headers: [String: String]?
      let statusCode: Int?
      let data: String?

      enum CodingKeys: String, CodingKey {
        case headers
        case statusCode = "status_code"
        case data
      }
    }

    // MARK:  App
    struct App: Codable {
      let appVersion: String
      let appIdentifier: String
      let appBuild: String
      let appName: String

      enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case appIdentifier = "app_identifier"
        case appBuild = "app_build"
        case appName = "app_name"
      }
    }

    // MARK:  Device
    struct Device: Codable {
      let modelId: String
      let simulator: Bool
      let model: String

      enum CodingKeys: String, CodingKey {
        case modelId = "model_id"
        case simulator
        case model
      }
    }

    // MARK:  OS
    struct OS: Codable {
      let name: String
      let version: String

      enum CodingKeys: String, CodingKey {
        case name
        case version
      }
    }

    let response: Response
    let app: App
    let os: OS
    let device: Device
  }

  // MARK:  Exception
  struct Exception: Codable {
    // MARK:  Value
    struct Value: Codable {
      let value: String
      let mechanism: Mechanism
      let type: String
    }

    let values: [Value]
  }

  // MARK:  Mechanism
  struct Mechanism: Codable {
    let type: String
  }

  // MARK:  Request
  struct Request: Codable {
    let url: String?
    let method: String?
    let fragment: String?
    let query: String?
    let headers: [String: String]?
    let data: [String: String]?
  }

  // MARK:  User
  struct User: Codable {
    let id: String
  }

  let exception: Exception
  let timestamp: Double
  let release, dist: String
  let level, platform: String
  let contexts: Contexts
  let request: Request
  let eventId, environment: String
  let user: User

  enum CodingKeys: String, CodingKey {
    case exception
    case timestamp
    case release
    case dist
    case level
    case platform
    case contexts
    case request
    case eventId = "event_id"
    case environment, user
  }
}
