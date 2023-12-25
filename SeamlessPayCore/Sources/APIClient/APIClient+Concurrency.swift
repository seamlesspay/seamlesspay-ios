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
  ) async throws -> PaymentMethod {
    return try await withCheckedThrowingContinuation { continuation in
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
        resume(continuation: continuation, accordingTo: result)
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
  ) async throws -> Customer {
    return try await withCheckedThrowingContinuation { continuation in
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
        resume(continuation: continuation, accordingTo: result)
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
  ) async throws -> Customer {
    return try await withCheckedThrowingContinuation { continuation in
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
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }

  func retrieveCustomer(
    id: String
  ) async throws -> Customer {
    return try await withCheckedThrowingContinuation { continuation in
      retrieveCustomer(
        id: id
      ) { result in
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }

  // MARK: Charge
  func createCharge(
    token: String,
    cvv: String? = nil,
    capture: Bool,
    currency: String? = nil,
    amount: String? = nil,
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
  ) async throws -> Charge {
    return try await withCheckedThrowingContinuation { continuation in
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
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }

  func retrieveCharge(
    id: String
  ) async throws -> Charge {
    return try await withCheckedThrowingContinuation { continuation in
      retrieveCharge(
        id: id
      ) { result in
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }

  func listCharges() async throws -> ChargePage {
    return try await withCheckedThrowingContinuation { continuation in
      listCharges { result in
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }

  func voidCharge(
    id: String
  ) async throws -> Charge {
    return try await withCheckedThrowingContinuation { continuation in
      voidCharge(id: id) { result in
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }

  // MARK: Verify
  func verify(
    token: String,
    cvv: String? = nil,
    currency: String? = nil,
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
  ) async throws -> Charge {
    return try await withCheckedThrowingContinuation { continuation in
      verify(
        token: token,
        cvv: cvv,
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
        resume(continuation: continuation, accordingTo: result)
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
  ) async throws -> Refund {
    return try await withCheckedThrowingContinuation { continuation in
      createRefund(
        token: token,
        amount: amount,
        currency: currency,
        descriptor: descriptor,
        idempotencyKey: idempotencyKey,
        metadata: metadata
      ) { result in
        resume(continuation: continuation, accordingTo: result)
      }
    }
  }
}

private func resume<T>(
  continuation: CheckedContinuation<T, Error>,
  accordingTo result: Result<T, SeamlessPayError>
) {
  switch result {
  case let .success(data):
    continuation.resume(returning: data)
  case let .failure(error):
    continuation.resume(throwing: error)
  }
}
