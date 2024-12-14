// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum ApplePayHandlerResult<Success, Failure> where Failure : Error {
  case success(Success)
  case failure(Failure)
  case canceled
}
