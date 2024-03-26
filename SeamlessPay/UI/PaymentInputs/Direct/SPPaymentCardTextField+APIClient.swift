// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: Init with Authorization
public extension SPPaymentCardTextField {
  convenience init(authorization: Authorization) {
    self.init()
    setAuthorization(authorization)
  }

  func setAuthorization(_ authorization: Authorization) {
    apiClient = .init(authorization: authorization)
  }
}

// MARK: APIClient instance
extension SPPaymentCardTextField {
  static var apiClientAssociationKey: Void?

  var apiClient: APIClient? {
    get {
      objc_getAssociatedObject(
        self,
        &Self.apiClientAssociationKey
      ) as? APIClient
    }
    set {
      objc_setAssociatedObject(
        self,
        &Self.apiClientAssociationKey,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
}
