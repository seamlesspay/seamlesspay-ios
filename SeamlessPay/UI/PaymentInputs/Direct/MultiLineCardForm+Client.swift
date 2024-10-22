// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Public
// MARK: Init with Authorization model
public extension MultiLineCardForm {
  convenience init(config: ClientConfiguration, fieldOptions: FieldOptions = .default) {
    self.init()
    viewModel.apiClient = .init(config: config)
    setCVCDisplayConfig(fieldOptions.cvv.display)
    setPostalCodeDisplayConfig(fieldOptions.postalCode.display)
  }
}

// MARK: Tokenize
public extension MultiLineCardForm {
  func tokenize(
    completion: ((Result<TokenizeResponse, SeamlessPayError>) -> Void)?
  ) {
    guard validateSubmission() else { return }

    viewModel.tokenize(completion: completion)
  }

  func tokenize() async -> Result<TokenizeResponse, SeamlessPayError>? {
    guard validateSubmission() else { return .none }

    return await viewModel.tokenize()
  }
}

// MARK: - Charge
public extension MultiLineCardForm {
  func charge(
    _ request: ChargeRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    guard validateSubmission() else { return }

    viewModel.charge(request, completion: completion)
  }

  func charge(
    _ request: ChargeRequest
  ) async -> Result<PaymentResponse, SeamlessPayError>? {
    guard validateSubmission() else { return .none }

    return await viewModel.charge(request)
  }
}

// MARK: - Refund
public extension MultiLineCardForm {
  func refund(
    _ request: RefundRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    guard validateSubmission() else { return }

    viewModel.refund(request, completion: completion)
  }

  func refund(
    _ request: RefundRequest
  ) async -> Result<PaymentResponse, SeamlessPayError>? {
    guard validateSubmission() else { return .none }

    return await viewModel.refund(request)
  }
}
