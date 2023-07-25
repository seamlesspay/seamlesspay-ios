// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

@objc public class SPSentryClient: NSObject {
  // MARK: Private variables
  private let dsn: SPSentryDSN
  private let config: SPSentryConfig

  private let session: URLSession

  // MARK: Init
  init?(dsn: String, config: SPSentryConfig) {
    guard let dsn = SPSentryDSN(string: dsn) else {
      return nil
    }
    self.dsn = dsn
    self.config = config
    session = URLSession(configuration: .default)
  }

  // MARK: Public
  @objc public static func makeWith(configuration: SPSentryConfig) -> SPSentryClient? {
    SPSentryClient(
      dsn: "https://3936eb5f56b34be7baf5eef81e5652ba@sentry.io/4505325448921088",
      config: configuration
    )
  }

  @objc public func captureFailedRequest(request: URLRequest, response: URLResponse) {
    send(
      event: .init(
        request: request,
        response: response
      )
    )
  }

  func send(event: SPSentryHTTPEvent) {
    guard let request = SentryNSURLRequest.makeStoreRequest(
      from: event,
      dsn: dsn
    ) else {
      print("Can't create store request")
      return
    }

    let task = session.dataTask(with: request) { data, response, error in
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          let string = String(
            describing: data.flatMap {
              String(
                data: $0,
                encoding: .utf8
              )
            }
          )
          print(
            "API response error sent successfully. Data is: \(string)"
          )
        } else {
          print("Failed to send API response error. Status code: \(httpResponse.statusCode)")
        }
      } else if let error = error {
        print("Error sending API response error: \(error)")
      }
    }

    task.resume()
  }
}

// MARK: Private
private extension SPSentryClient {}
