// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct APIError: LocalizedError {
  public struct FieldError {
    let message: String?
    let fieldName: String?
  }

  public let domain: String
  public let code: Int

  public var fieldErrors: [FieldError] {
    guard
      let data = data,
      let errorData = data["data"] as? [String: Any],
      let errors = errorData["errors"] as? [[String: Any]]
    else {
      return []
    }

    return errors.compactMap { error in
      return .init(
        message: error["message"] as? String,
        fieldName: error["fieldName"] as? String
      )
    }
  }

  let data: [String: Any]?

  public var errorDescription: String? {
    if let data {
      return Self.description(data)
    } else {
      return "Invalid response format"
    }
  }

  init(data: Data) {
    domain = "api.seamlesspay.com"

    let json = try? JSONSerialization.jsonObject(
      with: data,
      options: .allowFragments
    ) as? [String: Any]

    code = json?["code"] as? Int ?? 0

    self.data = json
  }
}

extension APIError {
  private static func description(_ dictionary: [String: Any]) -> String {
    var output = [String]()
    output.append(dictionary.stringFor("name"))
    output.append(dictionary.stringFor("message"))
    output.append(dictionary.stringFor("className"))
    if let data = dictionary["data"] as? [String: Any] {
      output.append(data.stringFor("statusCode"))
      output.append(data.stringFor("statusDescription"))

      if let errors = data["errors"] as? [[String: Any]] {
        output.append("Errors:")
        for (index, error) in errors.enumerated() {
          output.append(
            "#\(index + 1): \(error.stringFor("fieldName")) \(error.stringFor("message"))"
          )
        }
      }
    }

    return output.joined(separator: "\n")
  }
}

private extension [String: Any] {
  func stringFor(_ key: String) -> String {
    return "\(key.capitalized)=\(self[key] ?? "")"
  }
}
