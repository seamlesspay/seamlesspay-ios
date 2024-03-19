// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import SeamlessPay

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let publishableKey =
      UserDefaults.standard.string(forKey: "publishableKey") ?? "pk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
    let secretKey =
      UserDefaults.standard.string(forKey: "secretkey") ?? "sk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
    let envSaved = UserDefaults.standard.integer(forKey: "env")
    let env = Environment(rawValue: UInt(envSaved)) ?? .sandbox

    UserDefaults.standard.set(publishableKey, forKey: "publishableKey")
    UserDefaults.standard.set(secretKey, forKey: "secretkey")
    UserDefaults.standard.set(env.rawValue, forKey: "env")

    APIClient.shared.set(secretKey: secretKey, publishableKey: publishableKey, environment: env)

    return true
  }

  // MARK: UISceneSession Lifecycle
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
