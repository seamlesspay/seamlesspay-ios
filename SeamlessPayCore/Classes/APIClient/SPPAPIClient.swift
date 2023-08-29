// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// SPAPIClient is essentially a wrapper for APIClient, providing an Objective-C compatible
// interface.
// TODO: Move to a separate package
@objc public class SPPAPIClient: NSObject {
  private let client: APIClient
  @objc public init(
    secretKey: String? = nil,
    publishableKey: String,
    environment: Environment,
    subMerchantAccountId: String? = nil
  ) {
    client = APIClient(
      secretKey: secretKey,
      publishableKey: publishableKey,
      environment: environment,
      subMerchantAccountId: subMerchantAccountId
    )
    super.init()
  }

  // MARK: Obj-c wrappers
  @objc public func tokenize(
    paymentType: PaymentType,
    accountNumber: String,
    expirationDate: String,
    cvv: String,
    accountType: String,
    routing: String,
    pin: String,
    billingAddress: SPAddress,
    name: String,
    success: ((SPPaymentMethod) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.tokenize(
      paymentType: paymentType,
      accountNumber: accountNumber,
      expirationDate: expirationDate,
      cvv: cvv,
      accountType: accountType,
      routing: routing,
      pin: pin,
      billingAddress: billingAddress,
      name: name
    ) {
      switch $0 {
      case let .success(value):
        success?(value)
      case let .failure(error):
        failure?(error.spError)
      }
    }
  }
}
