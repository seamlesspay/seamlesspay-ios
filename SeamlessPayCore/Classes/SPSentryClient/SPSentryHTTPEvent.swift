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
  let app: App?
  let os: OS?
  let device: Device?
  let culture: Culture?
}

// MARK: - App
struct App: Codable {
  let buildType, appVersion, appIdentifier: String
  let appStartTime: Date
  let appID, deviceAppHash, appBuild: String
  let inForeground: Bool
  let appMemory: Int
  let appName: String

  enum CodingKeys: String, CodingKey {
    case buildType = "build_type"
    case appVersion = "app_version"
    case appIdentifier = "app_identifier"
    case appStartTime = "app_start_time"
    case appID = "app_id"
    case deviceAppHash = "device_app_hash"
    case appBuild = "app_build"
    case inForeground = "in_foreground"
    case appMemory = "app_memory"
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
  let bootTime: Date
  let processorCount: Int
  let modelID: String
  let freeMemory, storageSize: Int
  let family: String
  let screenHeightPixels: Int
  let simulator: Bool
  let freeStorage, screenWidthPixels: Int
  let locale, arch: String
  let memorySize: Int
  let model: String
  let usableMemory: Int

  enum CodingKeys: String, CodingKey {
    case bootTime = "boot_time"
    case processorCount = "processor_count"
    case modelID = "model_id"
    case freeMemory = "free_memory"
    case storageSize = "storage_size"
    case family
    case screenHeightPixels = "screen_height_pixels"
    case simulator
    case freeStorage = "free_storage"
    case screenWidthPixels = "screen_width_pixels"
    case locale, arch
    case memorySize = "memory_size"
    case model
    case usableMemory = "usable_memory"
  }
}

// MARK: - OS
struct OS: Codable {
  let version: String
  let rooted: Bool
  let kernelVersion, name, build: String

  enum CodingKeys: String, CodingKey {
    case version
    case rooted
    case kernelVersion = "kernel_version"
    case name, build
  }
}

// MARK: - Response
struct Response: Codable {
  let headers: [String: String]?
  let statusCode: Int?

  enum CodingKeys: String, CodingKey {
    case headers
    case statusCode = "status_code"
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
  init(request: URLRequest, response: URLResponse, sentryClientConfig: SPSentryConfig) {
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
        statusCode: response?.statusCode
      ),
      app: nil,
      os: nil,
      device: nil,
      culture: nil
    )

    let bundleIdentifier = systemDataProvider.app.bundleIdentifier
    let shortVersionString = systemDataProvider.app.appVersion
    let bundleVersion = systemDataProvider.app.appBuildVersion

    release = "\(bundleIdentifier)@\(shortVersionString)+\(bundleVersion)"
    dist = bundleVersion
    user = .init(id: sentryClientConfig.userId)
  }
}

extension SPSentryHTTPEvent {
  static func sentryEventId() -> String {
    UUID()
      .uuidString
      .replacingOccurrences(of: "-", with: "")
      .lowercased()
  }
}
