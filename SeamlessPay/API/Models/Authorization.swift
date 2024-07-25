// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct Authorization {
  public let secretKey: String
  public let proxyAccountId: String?
  public let environment: Environment

  public init(environment: Environment, secretKey: String, proxyAccountId: String? = nil) {
    self.secretKey = secretKey
    self.proxyAccountId = proxyAccountId
    self.environment = environment
  }
}
