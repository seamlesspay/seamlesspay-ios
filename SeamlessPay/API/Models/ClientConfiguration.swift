// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct ClientConfiguration: Hashable {
  public let environment: Environment
  public let secretKey: String
  public let proxyAccountId: String?

  public init(environment: Environment, secretKey: String, proxyAccountId: String? = .none) {
    self.secretKey = secretKey
    self.proxyAccountId = proxyAccountId
    self.environment = environment
  }
}
