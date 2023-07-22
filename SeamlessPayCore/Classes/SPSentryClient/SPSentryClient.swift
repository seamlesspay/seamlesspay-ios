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
  private let session: URLSession

  // MARK: Init
  init?(dsn: String) {
    guard let dsn = SPSentryDSN(string: dsn) else {
      return nil
    }
    self.dsn = dsn
    session = URLSession(configuration: .default)
  }

  // MARK: Public
  @objc public static func make() -> SPSentryClient? {
    SPSentryClient(
      dsn: "https://3936eb5f56b34be7baf5eef81e5652ba@o4504125304209408.ingest.sentry.io/https://o4504125304209408.ingest.sentry.io/api/4505325448921088/envelope/"
    )
  }

  @objc public func captureFailedRequest(task: URLSessionTask) {
    let envelope = SPSentryEnvelope(header: .init(eventId: ""), items: [.init()])
    send(envelope: envelope)
  }

  func send(envelope: SPSentryEnvelope) {}

  @objc public func sendEnvelope(error: NSError) {
    let request = SentryNSURLRequest.makeEnvelopeRequest(dsn: dsn, data: Data())
    let task = session.dataTask(with: request) { data, response, error in
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          print("API response error sent successfully.")
        } else {
          print(
            "Failed to send API response error. Status code: \(httpResponse.statusCode)"
          )
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
