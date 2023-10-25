// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum Environment: UInt {
  case sandbox
  case production
  case staging
  case qat
}

extension Environment {
  var name: String {
    switch self {
    case .sandbox:
      return "sandbox"
    case .production:
      return "production"
    case .staging:
      return "staging"
    case .qat:
      return "qat"
    }
  }

  var mainHost: String {
    switch self {
    case .sandbox:
      return "sandbox.seamlesspay.com"
    case .production:
      return "api.seamlesspay.com"
    case .staging:
      return "api.seamlesspay.dev"
    case .qat:
      return "api.seamlesspay.io"
    }
  }

  var panVaultHost: String {
    switch self {
    case .sandbox:
      return "sandbox-pan-vault.seamlesspay.com"
    case .production:
      return "pan-vault.seamlesspay.com"
    case .staging:
      return "pan-vault.seamlesspay.dev"
    case .qat:
      return "pan-vault.seamlesspay.io"
    }
  }
}
