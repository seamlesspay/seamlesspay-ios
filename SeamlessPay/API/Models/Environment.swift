// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum Environment: Int {
  case sandbox
  case production
  case staging
  case qat

  private enum SubDomain: String {
    case api
    case panVault = "pan-vault"
  }
}

public extension Environment {
  var name: String {
    String(describing: self)
  }

  var api: String {
    buildDomain(sub: .api)
  }

  var panVault: String {
    buildDomain(sub: .panVault)
  }
}

private extension Environment {
  var baseDomain: String {
    switch self {
    case .sandbox: return "sandbox.seamlesspay.com"
    case .production: return "seamlesspay.com"
    case .staging: return "seamlesspay.dev"
    case .qat: return "seamlesspay.io"
    }
  }

  private func buildDomain(sub: SubDomain) -> String {
    "\(sub.rawValue).\(baseDomain)"
  }
}
