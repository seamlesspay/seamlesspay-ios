// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: Interface
enum SPSentryHTTPEventFactory {
  static func event(
    request: URLRequest,
    response: URLResponse?,
    responseData: Data?,
    sentryClientConfig: SPSentryConfig,
    systemDataProvider: SPSentrySystemDataProvider = SPSentrySystemDataProvider.current
  ) -> SPSentryHTTPEvent {
    let url = request.url
    let response = response as? HTTPURLResponse

    let exception: SPSentryHTTPEvent.Exception = .init(
      values: [
        httpExceptionValueWith(statusCode: response?.statusCode),
      ]
    )

    let request: SPSentryHTTPEvent.Request = .init(
      url: url?.absoluteString,
      method: request.httpMethod,
      fragment: url?.fragment,
      query: url?.query,
      headers: request.allHTTPHeaderFields,
      data: request.httpBody.flatMap { maskValuesOf(data: $0) }
    )

    let headers = response?.allHeaderFields as? [String: String]

    let contexts: SPSentryHTTPEvent.Contexts = .init(
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
      )
    )

    let release =
      "\(systemDataProvider.app.bundleIdentifier)@\(systemDataProvider.app.version)+\(systemDataProvider.app.buildVersion)"

    return .init(
      exception: exception,
      timestamp: Date().timeIntervalSince1970,
      release: release,
      dist: systemDataProvider.app.buildVersion,
      level: "error",
      platform: "cocoa",
      contexts: contexts,
      request: request,
      eventId: sentryEventId(),
      environment: sentryClientConfig.environment,
      user: .init(id: sentryClientConfig.userId)
    )
  }
}

// MARK: Private
private extension SPSentryHTTPEventFactory {
  static func sentryEventId() -> String {
    UUID()
      .uuidString
      .replacingOccurrences(of: "-", with: "")
      .lowercased()
  }

  static func httpExceptionValueWith(statusCode: Int?) -> SPSentryHTTPEvent.Exception.Value {
    let statusCode = statusCode?.description ?? "nil"
    return .init(
      value: "HTTP Client Error with status code: \(statusCode)",
      mechanism: .init(
        type: "HTTPClientError"
      ),
      type: "HTTPClientError"
    )
  }

  static func maskValuesOf(data: Data) -> [String: String]? {
    do {
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

      guard let dictionary = jsonObject as? [String: Any] else {
        assertionFailure("Error: The data is not a valid dictionary.")
        return nil
      }

      return maskValuesRecursively(dictionary)
    } catch {
      assertionFailure("Error while parsing the data: \(error.localizedDescription)")
      return nil
    }
  }

  static func maskValuesRecursively(_ data: [String: Any]) -> [String: String] {
    var resultDictionary: [String: String] = [:]

    for (key, value) in data {
      if let nestedDictionary = value as? [String: Any] {
        // If the value is a nested dictionary, recursively call the function
        // to convert it to a string dictionary with hidden values
        let nestedHiddenDictionary =
          maskValuesRecursively(nestedDictionary)
        resultDictionary[key] = nestedHiddenDictionary.description
      } else {
        // For all other cases, replace the end value with "***"
        resultDictionary[key] = "***"
      }
    }

    return resultDictionary
  }
}
