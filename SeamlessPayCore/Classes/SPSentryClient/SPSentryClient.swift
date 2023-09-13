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
  private let queue = DispatchQueue(
    label: "com.seamlesspay.sentryclient.\(UUID().uuidString)",
    qos: .background
  )

  private let outputQueue = DispatchQueue(
    label: "com.seamlesspay.sentryclient.\(UUID().uuidString)",
    qos: .background
  )

  // MARK: Init
  init?(
    dsn: String,
    config: SPSentryConfig,
    session: URLSession = URLSession(configuration: .default)
  ) {
    guard let dsn = SPSentryDSNFactory.dsn(urlString: dsn) else {
      return nil
    }
    self.dsn = dsn
    self.config = config
    self.session = session
  }

  func send(
    event: SPSentryHTTPEvent,
    completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
  ) {
    guard let request = SPSentryURLRequestFactory.request(event: event, dsn: dsn) else {
      return
    }

    session.dataTask(
      with: request,
      completionHandler: completion
    )
    .resume()
  }
}

// MARK: Public
public extension SPSentryClient {
  @objc static func makeWith(configuration: SPSentryConfig) -> SPSentryClient? {
    SPSentryClient(
      dsn: "https://3936eb5f56b34be7baf5eef81e5652ba@sentry.io/4505325448921088",
      config: configuration
    )
  }

  @objc func captureFailedRequest(
    _ request: URLRequest,
    response: URLResponse?,
    responseData: Data?,
    completion: ((Data?, URLResponse?, Error?) -> Void)? = nil
  ) {
    queue.async {
      self.send(
        event: SPSentryHTTPEventFactory.event(
          request: request,
          response: response,
          responseData: responseData,
          sentryClientConfig: self.config
        )
      ) { data, response, error in
        self.outputQueue.async {
          completion?(data, response, error)
        }
      }
    }
  }
}
