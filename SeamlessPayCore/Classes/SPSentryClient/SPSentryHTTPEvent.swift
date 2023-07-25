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
  let eventID, environment: String
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
    case eventID = "event_id"
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
  init(request: URLRequest, response: URLResponse) {

    let url = request.url
    let response = response as? HTTPURLResponse

    exception = .init(
      values: [
        Value.httpExceptionValueWith(statusCode: response?.statusCode),
      ]
    )
    eventID = Self.sentryEventID()
    environment = "environment"
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
      os: nil, device: nil,
      culture: nil
    )

    let bundle = Bundle.main
    let bundleIdentifier = bundle.infoDictionaryStringValue(key: "CFBundleIdentifier")
    let shortVersionString = bundle.infoDictionaryStringValue(key: "CFBundleShortVersionString")
    let bundleVersion = bundle.infoDictionaryStringValue(key: "CFBundleVersion")

    release = "\(bundleIdentifier)@\(shortVersionString)+\(bundleVersion)"
    dist = bundleVersion
    user = .init(id: "id-foo")
  }
}

extension SPSentryHTTPEvent {
  static func sentryEventID() -> String {
    UUID()
      .uuidString
      .replacingOccurrences(of: "-", with: "")
      .lowercased()
  }
}

// struct SPSentryHTTPEvent: Codable {
//  struct Request: Codable {
//    let url: String?
//    let method: String?
//    let fragment: String?
//    let query: String?
//    let bodySize: Int?
//    let headers: [String: String]?
//    let cookies: String?
//  }
//
//  struct Exception {
//    struct Value {
//
//    }
//
//    let values: [Value]
//  }
//
//  struct Response: Codable {
//    let statusCode: String?
//    let headers: [String: String]?
//    let cookies: String?
//  }
//
//  struct Context: Codable {
//    let response: Response
//  }
//
//  let platform: String
//  let level: String
//  let eventId: String
//  let timestamp: TimeInterval
//  let request: Request
//  let context: Context
//  let release: String?
//  let dist: String?
//
//  // CodingKeys to specify custom key mappings
//  enum CodingKeys: String, CodingKey {
//      case platform
//      case level
//      case eventId = "event_id"
//      case timestamp
//      case request
//      case context
//      case release
//      case dist
//  }
//
//  // Nested CodingKeys for nested structures
//  enum RequestCodingKeys: String, CodingKey {
//      case url
//      case method
//      case fragment
//      case query
//      case bodySize = "body_size"
//      case headers
//      case cookies
//  }
//
//  enum ResponseCodingKeys: String, CodingKey {
//      case statusCode = "status_code"
//      case headers
//      case cookies
////      case bodySize = "body_size"
//  }
//
//  enum ContextCodingKeys: String, CodingKey {
//      case response
//  }
//
//  // Implement the init(from:) initializer to handle decoding
//  init(from decoder: Decoder) throws {
//      let container = try decoder.container(keyedBy: CodingKeys.self)
//
//      platform = try container.decode(String.self, forKey: .platform)
//      level = try container.decode(String.self, forKey: .level)
//      eventId = try container.decode(String.self, forKey: .eventId)
//      timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
//      request = try container.decode(Request.self, forKey: .request)
//      context = try container.decode(Context.self, forKey: .context)
//      release = try container.decodeIfPresent(String.self, forKey: .release)
//      dist = try container.decodeIfPresent(String.self, forKey: .dist)
//  }
//
//  // Implement the encode(to:) method to handle encoding
//  func encode(to encoder: Encoder) throws {
//      var container = encoder.container(keyedBy: CodingKeys.self)
//
//      try container.encode(platform, forKey: .platform)
//      try container.encode(level, forKey: .level)
//      try container.encode(eventId, forKey: .eventId)
//      try container.encode(timestamp, forKey: .timestamp)
//      try container.encode(request, forKey: .request)
//      try container.encode(context, forKey: .context)
//      try container.encodeIfPresent(release, forKey: .release)
//      try container.encodeIfPresent(dist, forKey: .dist)
//  }
//
//  init(request: URLRequest, response: URLResponse) {
//    eventId = UUID()
//      .uuidString
//      .replacingOccurrences(of: "-", with: "")
//      .lowercased()
//    platform = "cocoa"
//    level = "error"
//    timestamp = Date().timeIntervalSince1970
//
//    let taskURL = request.url
//    let response = response as? HTTPURLResponse
//
//    self.request = .init(
//      url: taskURL?.absoluteString,
//      method: request.httpMethod,
//      fragment: taskURL?.fragment,
//      query: taskURL?.query,
//      bodySize: request.httpBody?.count,
//      headers: request.allHTTPHeaderFields,
//      cookies: request.allHTTPHeaderFields?["Cookie"]
//    )
//
//    let headers = response?.allHeaderFields as? [String: String]
//
//    context = .init(
//      response: .init(
//        statusCode: response?.statusCode.description,
//        headers: headers,
//        cookies: headers?["Set-Cookie"]
//      )
//    )
//
//    let bundle = Bundle.main
//    let bundleIdentifier = bundle.infoDictionaryStringValue(key: "CFBundleIdentifier")
//    let shortVersionString = bundle.infoDictionaryStringValue(key: "CFBundleShortVersionString")
//    let bundleVersion = bundle.infoDictionaryStringValue(key: "CFBundleVersion")
//
//    release = "\(bundleIdentifier)@\(shortVersionString)+\(bundleVersion)"
//    dist = bundleVersion
//  }
// }

private extension Bundle {
  func infoDictionaryStringValue(key: String) -> String {
    return (infoDictionary?[key] as? String) ?? ""
  }
}
