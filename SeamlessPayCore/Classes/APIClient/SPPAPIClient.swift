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
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func createCustomer(
    name: String,
    email: String,
    address: SPAddress? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [SPPaymentMethod]? = nil,
    metadata: String? = nil,
    success: ((SPCustomer) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.createCustomer(
      name: name,
      email: email,
      address: address,
      companyName: companyName,
      notes: notes,
      phone: phone,
      website: website,
      paymentMethods: paymentMethods,
      metadata: metadata
    ) {
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func updateCustomer(
    id: String,
    name: String,
    email: String,
    address: SPAddress? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [SPPaymentMethod]? = nil,
    metadata: String? = nil,
    success: ((SPCustomer) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.updateCustomer(
      id: id,
      name: name,
      email: email,
      address: address,
      companyName: companyName,
      notes: notes,
      phone: phone,
      website: website,
      paymentMethods: paymentMethods
    ) {
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func retrieveCustomer(
    id: String,
    success: ((SPCustomer) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.retrieveCustomer(id: id) {
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func createCharge(
    token: String,
    cvv: String? = nil,
    capture: Bool,
    currency: String? = nil,
    amount: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderId: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    success: ((SPCharge) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.createCharge(
      token: token,
      cvv: cvv,
      capture: capture,
      currency: currency,
      amount: amount,
      taxAmount: taxAmount,
      taxExempt: taxExempt,
      tip: tip,
      surchargeFeeAmount: surchargeFeeAmount,
      description: description,
      order: order,
      orderId: orderId,
      poNumber: poNumber,
      metadata: metadata,
      descriptor: descriptor,
      entryType: entryType,
      idempotencyKey: idempotencyKey
    ) {
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func retrieveCharge(
    id: String,
    success: ((SPCharge) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.retrieveCharge(id: id) {
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func listCharges(
    success: (([String: Any]) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.listCharges {
      mapResult($0, success: success, failure: failure)
    }
  }

  @objc public func verify(
    token: String,
    cvv: String? = nil,
    currency: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderId: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    success: ((SPCharge) -> Void)?,
    failure: ((SPError) -> Void)?
  ) {
    client.verify(
      token: token,
      cvv: cvv,
      currency: currency,
      taxAmount: taxAmount,
      taxExempt: taxExempt,
      tip: tip,
      surchargeFeeAmount: surchargeFeeAmount,
      description: description,
      order: order,
      orderId: orderId,
      poNumber: poNumber,
      metadata: metadata,
      descriptor: descriptor,
      entryType: entryType,
      idempotencyKey: idempotencyKey
    ) {
      mapResult($0, success: success, failure: failure)
    }
  }
}

private func mapResult<Success>(
  _ result: Result<Success, SeamlessPayError>,
  success: ((Success) -> Void)?,
  failure: ((SPError) -> Void)?
) {
  switch result {
  case let .success(value):
    success?(value)
  case let .failure(error):
    failure?(error.spError)
  }
}
