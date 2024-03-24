// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct Authorization {
  public let environment: Environment
  public let secretKey: String

  public init(environment: Environment, secretKey: String) {
    self.environment = environment
    self.secretKey = secretKey
  }
}
