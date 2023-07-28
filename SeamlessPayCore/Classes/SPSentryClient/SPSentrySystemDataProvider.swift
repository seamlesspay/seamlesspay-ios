// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

struct SPSentrySystemDataProvider {
  struct Device {
    let model: String
    let name: String
    let systemName: String
    let systemVersion: String
    var isSimulator: Bool {
      #if targetEnvironment(simulator)
        return true
      #else
        return false
      #endif
    }
  }

  struct App {
    let bundleIdentifier: String
    let name: String
    let version: String
    let buildVersion: String
  }

  let device: Device
  let app: App

  static var current: SPSentrySystemDataProvider {
    let device = Device(
      model: UIDevice.current.model,
      name: UIDevice.current.name,
      systemName: UIDevice.current.systemName,
      systemVersion: UIDevice.current.systemVersion
    )

    let app = App(
      bundleIdentifier: Bundle.main.infoDictionaryStringValue(key: "CFBundleIdentifier"),
      name: Bundle.main.infoDictionaryStringValue(key: "CFBundleName"),
      version: Bundle.main.infoDictionaryStringValue(key: "CFBundleShortVersionString"),
      buildVersion: Bundle.main.infoDictionaryStringValue(key: "CFBundleVersion")
    )

    return SPSentrySystemDataProvider(device: device, app: app)
  }
}

private extension Bundle {
  func infoDictionaryStringValue(key: String) -> String {
    return (infoDictionary?[key] as? String) ?? ""
  }
}
