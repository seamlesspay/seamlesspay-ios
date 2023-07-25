// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

struct SPSentrySystemDataProvider {
  struct DeviceData {
    let deviceModel: String
    let deviceName: String
    let systemName: String
    let systemVersion: String
  }

  struct AppData {
    let bundleIdentifier: String
    let appName: String
    let appVersion: String
    let appBuildVersion: String
  }

  let device: DeviceData
  let app: AppData

  static var current: SPSentrySystemDataProvider {
    let device = DeviceData(
      deviceModel: UIDevice.current.model,
      deviceName: UIDevice.current.name,
      systemName: UIDevice.current.systemName,
      systemVersion: UIDevice.current.systemVersion
    )

    let app = AppData(
      bundleIdentifier: Bundle.main.infoDictionaryStringValue(key: "CFBundleIdentifier"),
      appName: Bundle.main.infoDictionaryStringValue(key: "CFBundleName"),
      appVersion: Bundle.main.infoDictionaryStringValue(key: "CFBundleShortVersionString"),
      appBuildVersion: Bundle.main.infoDictionaryStringValue(key: "CFBundleVersion")
    )

    return SPSentrySystemDataProvider(device: device, app: app)
  }
}

private extension Bundle {
  func infoDictionaryStringValue(key: String) -> String {
    return (infoDictionary?[key] as? String) ?? ""
  }
}
