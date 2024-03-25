// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
#if canImport(SeamlessPayObjC)
  import SeamlessPayAPI
  import SeamlessPayObjC
#endif

// MARK: Init with Authorization
public extension SPPaymentCardTextField {
  convenience init(authorization: Authorization) {
    self.init()

    let spEnv: SPEnvironment
    switch authorization.environment {
    case .sandbox:
      spEnv = .sandbox
    case .production:
      spEnv = .production
    case .qat:
      spEnv = .qat
    case .staging:
      spEnv = .staging
    }

    setAuthorization(spEnv, andSecretKey: authorization.secretKey)
  }
}
