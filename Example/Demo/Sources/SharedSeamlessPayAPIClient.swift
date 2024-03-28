// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation
import SeamlessPay

private(set) var sharedSeamlessPayAPIClient: APIClient = .init(
  authorization: sharedSeamlessPayAPIClientAuthorization
)

var sharedSeamlessPayAPIClientAuthorization: Authorization {
  get {
    let environment = Environment(
      rawValue: UserDefaults.standard.integer(forKey: "env")
    ) ?? defaultAuthorization.environment

    let secretKey = UserDefaults.standard.string(
      forKey: "secretkey"
    ) ?? defaultAuthorization.secretKey

    return Authorization(
      environment: environment,
      secretKey: secretKey
    )
  }
  set {
    UserDefaults.standard.set(newValue.secretKey, forKey: "secretkey")
    UserDefaults.standard.set(newValue.environment.rawValue, forKey: "env")

    sharedSeamlessPayAPIClient = .init(
      authorization: sharedSeamlessPayAPIClientAuthorization
    )
  }
}

private var defaultAuthorization: Authorization {
  Authorization(
    environment: .sandbox,
    secretKey: "sk_XXXXXXXXXXXXXXXXXXXXXXXXXX"
  )
}
