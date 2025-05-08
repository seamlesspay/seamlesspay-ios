// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public class SPSentryConfig: NSObject {
  public enum Environment: String {
    case SBX
    case PRO
    case STG
    case QAT
  }
  
  let userId: String
  let environment: SPSentryConfig.Environment

  public init(userId: String, environment: SPSentryConfig.Environment) {
    self.userId = userId
    self.environment = environment
  }
}
