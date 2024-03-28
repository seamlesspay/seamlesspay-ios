// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

enum DeviceFingerprint {
  static func make(appOpenTime: Date?, apiVersion: String) -> String? {
    let code = Locale.current.languageCode
    let language = code.flatMap { Locale.current.localizedString(forLanguageCode: $0) }
    let timeOnPage = appOpenTime
      .flatMap { Date().timeIntervalSince($0) }
      .flatMap { Int($0 * 1000) }

    let hoursTimeZoneOffset = TimeZone.current.secondsFromGMT() / 3600
    let timeZoneOffset = String(hoursTimeZoneOffset)

    let dict: [String: Any] = [
      "fingerprint": UIDevice.current.identifierForVendor?.uuidString ?? "undefined",
      "components": [
        component(key: "user_agent", value: "ios sdk \(apiVersion)"),
        component(key: "language", value: language),
        component(key: "locale_id", value: Locale.current.identifier),
        component(key: "name", value: UIDevice.current.name),
        component(key: "system_name", value: UIDevice.current.systemName),
        component(key: "model", value: UIDevice.current.model),
        component(key: "localized_model", value: UIDevice.current.localizedModel),
        component(key: "user_interface_idiom", value: "\(UIDevice.current.userInterfaceIdiom)"),
        component(key: "time_on_page", value: timeOnPage),
        component(key: "time_zone_offset", value: timeZoneOffset),
        component(
          key: "resolution",
          value: [
            UIScreen.main.bounds.size.width,
            UIScreen.main.bounds.size.height,
          ]
        ),
      ],
    ]

    guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
      return nil
    }
    let jsonString = String(data: jsonData, encoding: .utf8)
    let data = jsonString?.data(using: .utf8)
    return data?.base64EncodedString(options: [])
  }

  private static func component(key: String, value: Any?) -> [String: Any] {
    [
      "key": key,
      "value": value ?? "undefined",
    ]
  }
}
