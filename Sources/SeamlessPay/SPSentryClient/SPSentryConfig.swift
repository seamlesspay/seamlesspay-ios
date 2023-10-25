// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public class SPSentryConfig: NSObject {
  let userId: String
  let environment: String

  public init(userId: String, environment: String) {
    self.userId = userId
    self.environment = environment
  }
}
