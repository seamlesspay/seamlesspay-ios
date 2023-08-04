// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: Interface
enum SPSentryURLRequestFactory {
  static func request(event: SPSentryHTTPEvent, dsn: SPSentryDSN) -> URLRequest? {
    guard let data = try? JSONEncoder().encode(event) else {
      return nil
    }
    let apiURL = dsn.storeEndpoint

    var request = URLRequest(
      url: apiURL,
      cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: C.requestTimeout
    )

    request.httpMethod = "POST"
    request.setValue(authHeader(url: dsn.url), forHTTPHeaderField: "X-Sentry-Auth")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(dsn.url.host, forHTTPHeaderField: "Host")
    request.setValue(C.userAgent, forHTTPHeaderField: "User-Agent")
    request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
    request.httpBody = data

    return request
  }
}

// MARK: Constants
private extension SPSentryURLRequestFactory {
  // MARK: Constants
  enum C {
    static let requestTimeout: TimeInterval = 15
    static let userAgent = "seamlesspay-ios-sentry-client"
    static let userAgentVersion = "0.1"
    static let sentryVersion = "7"
  }
}

// MARK: Private
private extension SPSentryURLRequestFactory {
  static func authHeader(url: URL) -> String? {
    guard let sentryKey = url.user else {
      return nil
    }

    let start = "Sentry"
    let components: String = [
      "sentry_version": C.sentryVersion,
      "sentry_client": "\(C.userAgent)/\(C.userAgentVersion)",
      "sentry_key": sentryKey,
      "sentry_secret": url.password,
    ]
    .compactMapValues { $0 }
    .map {
      "\($0.key)=\($0.value)"
    }
    .joined(separator: ",")

    return [
      start,
      components,
    ]
    .joined(separator: " ")
  }
}
