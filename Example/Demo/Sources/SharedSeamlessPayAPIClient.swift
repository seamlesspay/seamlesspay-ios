// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation
import SeamlessPay

var sharedSPAuthorization: Authorization {
  get {
    let environment = Environment(
      rawValue: UserDefaults.standard.integer(forKey: "env")
    ) ?? mockSPAuthorization.environment

    let secretKey = UserDefaults.standard.string(
      forKey: "secretkey"
    ) ?? mockSPAuthorization.secretKey

    return Authorization(
      environment: environment,
      secretKey: secretKey
    )
  }
  set {
    UserDefaults.standard.set(newValue.secretKey, forKey: "secretkey")
    UserDefaults.standard.set(newValue.environment.rawValue, forKey: "env")
  }
}

var mockSPAuthorization: Authorization {
  Authorization(
    environment: .sandbox,
    secretKey: "sk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
  )
}
