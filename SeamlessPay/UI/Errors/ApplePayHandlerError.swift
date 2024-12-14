// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum ApplePayHandlerError: Error {
    case seamlessPayError(SeamlessPayError) // Errors returned by SeamlessPay
    case passKitError(Error) // Errors returned by Apple
}
