// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public extension APIClient {
  // MARK: Tokenize
  func tokenize(
    paymentType: PaymentType,
    accountNumber: String,
    expDate: ExpirationDate? = nil,
    cvv: String? = nil,
    accountType: String? = nil,
    routing: String? = nil,
    pin: String? = nil,
    billingAddress: Address? = nil,
    name: String? = nil
  ) async -> Result<PaymentMethod, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      tokenize(
        paymentType: paymentType,
        accountNumber: accountNumber,
        expDate: expDate,
        cvv: cvv,
        accountType: accountType,
        routing: routing,
        pin: pin,
        billingAddress: billingAddress,
        name: name
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }

  // MARK: Customer
  func createCustomer(
    name: String,
    email: String,
    address: Address? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [PaymentMethod]? = nil,
    metadata: String? = nil
  ) async -> Result<Customer, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      createCustomer(
        name: name,
        email: email,
        address: address,
        companyName: companyName,
        notes: notes,
        phone: phone,
        website: website,
        paymentMethods: paymentMethods,
        metadata: metadata
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }

  func updateCustomer(
    id: String,
    name: String,
    email: String,
    address: Address? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [PaymentMethod]? = nil,
    metadata: String? = nil
  ) async -> Result<Customer, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      updateCustomer(
        id: id,
        name: name,
        email: email,
        address: address,
        companyName: companyName,
        notes: notes,
        phone: phone,
        website: website,
        paymentMethods: paymentMethods
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }

  func retrieveCustomer(
    id: String
  ) async -> Result<Customer, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      retrieveCustomer(
        id: id
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }

  // MARK: Charge
  func createCharge(
    token: String,
    cvv: String? = nil,
    capture: Bool? = false,
    currency: String? = nil,
    amount: String,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderID: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil
  ) async -> Result<Charge, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      createCharge(
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
        orderID: orderID,
        poNumber: poNumber,
        metadata: metadata,
        descriptor: descriptor,
        entryType: entryType,
        idempotencyKey: idempotencyKey
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }

  func retrieveCharge(
    id: String
  ) async -> Result<Charge, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      retrieveCharge(
        id: id
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }

  func listCharges() async -> Result<ChargePage, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      listCharges { result in
        continuation.resume(returning: result)
      }
    }
  }

  func voidCharge(
    id: String
  ) async -> Result<Charge, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      voidCharge(id: id) { result in
        continuation.resume(returning: result)
      }
    }
  }

  // MARK: Refunds
  func createRefund(
    token: String,
    amount: String,
    currency: String? = nil,
    descriptor: String? = nil,
    idempotencyKey: String? = nil,
    metadata: String? = nil
  ) async -> Result<Refund, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      createRefund(
        token: token,
        amount: amount,
        currency: currency,
        descriptor: descriptor,
        idempotencyKey: idempotencyKey,
        metadata: metadata
      ) { result in
        continuation.resume(returning: result)
      }
    }
  }
}
