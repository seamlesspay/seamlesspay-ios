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
    expDate: ExpirationDate? = .none,
    cvv: String? = .none,
    accountType: String? = .none,
    routing: String? = .none,
    pin: String? = .none,
    billingAddress: Address? = .none,
    name: String? = .none
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
    address: Address? = .none,
    companyName: String? = .none,
    notes: String? = .none,
    phone: String? = .none,
    website: String? = .none,
    paymentMethods: [PaymentMethod]? = .none,
    metadata: String? = .none
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
    address: Address? = .none,
    companyName: String? = .none,
    notes: String? = .none,
    phone: String? = .none,
    website: String? = .none,
    paymentMethods: [PaymentMethod]? = .none,
    metadata: String? = .none
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
    cvv: String? = .none,
    capture: Bool? = false,
    currency: String? = .none,
    amount: Int,
    taxAmount: Int? = .none,
    taxExempt: Bool? = .none,
    tip: Int? = .none,
    surchargeFeeAmount: Int? = .none,
    description: String? = .none,
    order: [String: String]? = .none,
    orderID: String? = .none,
    poNumber: String? = .none,
    metadata: String? = .none,
    descriptor: String? = .none,
    entryType: String? = .none,
    idempotencyKey: String? = .none
  ) async -> Result<Charge, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      createCharge(
        token: token,
        amount: amount,
        cvv: cvv,
        capture: capture,
        currency: currency,
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
    amount: Int,
    currency: String? = .none,
    descriptor: String? = .none,
    idempotencyKey: String? = .none,
    metadata: String? = .none
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

extension APIClient {
  // MARK: SDK Data
  func retrieveSDKData() async -> Result<SDKData, SeamlessPayError> {
    await withCheckedContinuation { continuation in
      retrieveSDKData { result in
        continuation.resume(returning: result)
      }
    }
  }
}
