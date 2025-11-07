// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: Tokenize
public extension CardForm {
  func tokenize(
    completion: ((Result<TokenizeResponse, APIError>?) -> Void)?
  ) {
    guard validateForm() else {
      completion?(.none)
      return
    }

    viewModel.tokenize { result in
      if case let .failure(error) = result {
        DispatchQueue.main.async { [weak self] in
          self?.handleAPIError(error)
        }
      }

      completion?(result)
    }
  }

  func tokenize() async -> Result<TokenizeResponse, APIError>? {
    await withCheckedContinuation { continuation in
      tokenize { result in
        continuation.resume(returning: result)
      }
    }
  }
}

// MARK: - Charge
public extension CardForm {
  func charge(
    _ request: ChargeRequest,
    completion: ((Result<PaymentResponse, APIError>?) -> Void)?
  ) {
    guard validateForm() else {
      completion?(.none)
      return
    }

    viewModel.charge(request, completion: completion)
  }

  func charge(
    _ request: ChargeRequest
  ) async -> Result<PaymentResponse, APIError>? {
    guard validateForm() else { return .none }

    return await viewModel.charge(request)
  }
}

// MARK: - Refund
public extension CardForm {
  func refund(
    _ request: RefundRequest,
    completion: ((Result<PaymentResponse, APIError>?) -> Void)?
  ) {
    guard validateForm() else {
      completion?(.none)
      return
    }

    viewModel.refund(request, completion: completion)
  }

  func refund(
    _ request: RefundRequest
  ) async -> Result<PaymentResponse, APIError>? {
    guard validateForm() else { return .none }

    return await viewModel.refund(request)
  }
}
