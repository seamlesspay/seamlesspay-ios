// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - SPSentryHTTPEvent
struct SPSentryHTTPEvent: Codable {
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

// MARK: - Contexts
struct Contexts: Codable {
  let response: Response
  let app: App
  let os: OS
  let device: Device
  let culture: Culture?
}

// MARK: - App
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

// MARK: - Culture
struct Culture: Codable {
  let locale, timezone, displayName, calendar: String
  let is24_HourFormat: Bool

  enum CodingKeys: String, CodingKey {
    case locale
    case timezone
    case displayName = "display_name"
    case calendar
    case is24_HourFormat = "is_24_hour_format"
  }
}

// MARK: - Device
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

// MARK: - OS
struct OS: Codable {
  let name: String
  let version: String

  enum CodingKeys: String, CodingKey {
    case name
    case version
  }
}

// MARK: - Response
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

// MARK: - Exception
struct Exception: Codable {
  let values: [Value]
}

// MARK: - Value
struct Value: Codable {
  let value: String
  let mechanism: Mechanism
  let type: String

  static func httpExceptionValueWith(statusCode: Int?) -> Value {
    let statusCode = statusCode?.description ?? "nil"
    return .init(
      value: "HTTP Client Error with status code: \(statusCode)",
      mechanism: .init(
        type: "HTTPClientError"
      ),
      type: "HTTPClientError"
    )
  }
}

// MARK: - Mechanism
struct Mechanism: Codable {
  let type: String
}

// MARK: - Request
struct Request: Codable {
  let url: String?
  let method: String?
  let fragment: String?
  let query: String?
  let headers: [String: String]?
}

// MARK: - User
struct User: Codable {
  let id: String
}

extension SPSentryHTTPEvent {
  init(
    request: URLRequest,
    response: URLResponse,
    responseData: Data?,
    sentryClientConfig: SPSentryConfig
  ) {
    let systemDataProvider = SPSentrySystemDataProvider.current
    let url = request.url
    let response = response as? HTTPURLResponse

    exception = .init(
      values: [
        Value.httpExceptionValueWith(statusCode: response?.statusCode),
      ]
    )
    eventId = Self.sentryEventId()
    environment = sentryClientConfig.environment
    platform = "cocoa"
    level = "error"
    timestamp = Date().timeIntervalSince1970

    self.request = .init(
      url: url?.absoluteString,
      method: request.httpMethod,
      fragment: url?.fragment,
      query: url?.query,
      headers: request.allHTTPHeaderFields
    )

    let headers = response?.allHeaderFields as? [String: String]

    contexts = .init(
      response: .init(
        headers: headers,
        statusCode: response?.statusCode,
        data: responseData.flatMap { String(data: $0, encoding: .utf8) }
      ),
      app: .init(
        appVersion: systemDataProvider.app.version,
        appIdentifier: systemDataProvider.app.bundleIdentifier,
        appBuild: systemDataProvider.app.buildVersion,
        appName: systemDataProvider.app.name
      ),
      os: .init(
        name: systemDataProvider.device.systemName,
        version: systemDataProvider.device.systemVersion
      ),
      device: .init(
        modelId: systemDataProvider.device.isSimulator ? "simulator" : systemDataProvider.device
          .model,
        simulator: systemDataProvider.device.isSimulator,
        model: systemDataProvider.device.name
      ),
      culture: nil
    )

    let bundleIdentifier = systemDataProvider.app.bundleIdentifier
    let shortVersionString = systemDataProvider.app.version
    let bundleVersion = systemDataProvider.app.buildVersion

    release = "\(bundleIdentifier)@\(shortVersionString)+\(bundleVersion)"
    dist = bundleVersion
    user = .init(id: sentryClientConfig.userId)
  }
}

private extension SPSentryHTTPEvent {
  static func sentryEventId() -> String {
    UUID()
      .uuidString
      .replacingOccurrences(of: "-", with: "")
      .lowercased()
  }
}
