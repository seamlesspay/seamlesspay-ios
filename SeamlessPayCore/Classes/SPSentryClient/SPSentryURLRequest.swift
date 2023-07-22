// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

struct SentryNSURLRequest {
  private enum C {
    static let requestTimeout: TimeInterval = 15
    static let sdkName = "sentry.cocoa"
    static let sdkVersion = "8.8.0"
  }

  static func makeEnvelopeRequest(dsn: SPSentryDSN, data: Data) -> URLRequest {
    let apiURL = dsn.envelopeEndpoint

    var request = URLRequest(
      url: apiURL,
      cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: C.requestTimeout
    )
    let authHeader = authHeader(url: dsn.url)

    request.httpMethod = "POST"
    request.setValue(
      authHeader,
      forHTTPHeaderField: "X-Sentry-Auth"
    )
    request.setValue(
      "application/x-sentry-envelope",
      forHTTPHeaderField: "Content-Type"
    )
    request.setValue(
      C.sdkName,
      forHTTPHeaderField: "User-Agent"
    )
    request.setValue(
      "gzip",
      forHTTPHeaderField: "Content-Encoding"
    )

//      request.httpBody = data.sentry_gzipped(withCompressionLevel: -1, error: &error)

    return request
  }
}

private extension SentryNSURLRequest {
  static func newHeaderPart(key: String, value: Any) -> String {
    return "\(key)=\(value)"
  }

  static func authHeader(url: URL) -> String? {
    guard let sentryKey = url.user else {
      return nil
    }

    let start = "Sentry"
    let components: String = [
      "sentry_version": C.sdkVersion,
      "sentry_client": "\(C.sdkName)/\(C.sdkVersion)",
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
