// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

@objc(SPPEnvironment) public enum Environment: Int {
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

  var baseURL: String {
    switch self {
    case .sandbox:
      return "https://sandbox.seamlesspay.com"
    case .production:
      return "https://api.seamlesspay.com"
    case .staging:
      return "https://api.seamlesspay.dev"
    case .qat:
      return "https://api.seamlesspay.io"
    }
  }

  var panVaultBaseURL: String {
    switch self {
    case .sandbox:
      return "https://sandbox-pan-vault.seamlesspay.com"
    case .production:
      return "https://pan-vault.seamlesspay.com"
    case .staging:
      return "https://pan-vault.seamlesspay.dev"
    case .qat:
      return "https://pan-vault.seamlesspay.io"
    }
  }
}
