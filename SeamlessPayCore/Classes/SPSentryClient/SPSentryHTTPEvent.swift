// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

struct SPSentryHTTPEvent {
  struct Request {
    let url: String?
    let method: String?
    let fragment: String?
    let queryString: String?
    let bodySize: Int
    let headers: [String: String]?
    let cookies: String?
  }

  // MARK: Constants
  let platform = "cocoa"
  let level = 4

  let eventId: String
  let timestamp = Date()
  let request: Request
  let context: [String: Any]
  let releaseName: String?
  let dist: String?

  init(eventId: String, sessionTask: URLSessionDataTask) {
    self.eventId = eventId

    let taskURL = sessionTask.currentRequest?.url
    let taskRequest = sessionTask.currentRequest
    let taskResponse = sessionTask.response as? HTTPURLResponse

    request = .init(
      url: taskURL?.absoluteString,
      method: taskRequest?.httpMethod,
      fragment: taskURL?.fragment,
      queryString: taskURL?.query,
      bodySize: Int(sessionTask.countOfBytesSent),
      headers: taskRequest?.allHTTPHeaderFields,
      cookies: taskRequest?.allHTTPHeaderFields?["Cookie"]
    )

    var context: [String: Any] = [:]
    var response: [String: Any] = [:]

    if let taskResponse = taskResponse {
      response["status_code"] = taskResponse.statusCode.description
      response["headers"] = taskResponse.allHeaderFields
      response["cookies"] = taskResponse.allHeaderFields["Set-Cookie"]
    }

    if sessionTask.countOfBytesReceived != 0 {
      response["body_size"] = sessionTask.countOfBytesReceived
    }

    context["response"] = response
    self.context = context

    let infoDict = Bundle.main.infoDictionary

    let bundleIdentifier = String(describing: infoDict?["CFBundleIdentifier"])
    let shortVersionString = String(describing: infoDict?["CFBundleShortVersionString"])
    let bundleVersion = String(describing: infoDict?["CFBundleVersion"])

    releaseName = "\(bundleIdentifier)@\(shortVersionString)+\(bundleVersion)"
    dist = bundleVersion
  }
}
