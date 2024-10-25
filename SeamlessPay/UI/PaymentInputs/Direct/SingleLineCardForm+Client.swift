// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

// MARK: - Public
// MARK: Init with Authorization model
public extension SingleLineCardForm {
  convenience init(config: ClientConfiguration, fieldOptions: FieldOptions = .default) {
    self.init()
    viewModel.apiClient = .init(config: config)
    
    setCVCDisplayConfig(fieldOptions.cvv.display)
    setPostalCodeDisplayConfig(fieldOptions.postalCode.display)
  }
}

// MARK: Tokenize
public extension SingleLineCardForm {
  func tokenize(
    completion: ((Result<TokenizeResponse, SeamlessPayError>) -> Void)?
  ) {
    viewModel.tokenize(completion: completion)
  }

  func tokenize() async -> Result<TokenizeResponse, SeamlessPayError> {
    await viewModel.tokenize()
  }
}

// MARK: - Charge
public extension SingleLineCardForm {
  func charge(
    _ request: ChargeRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    viewModel.charge(request, completion: completion)
  }

  func charge(
    _ request: ChargeRequest
  ) async -> Result<PaymentResponse, SeamlessPayError> {
    await viewModel.charge(request)
  }
}

// MARK: - Refund
public extension SingleLineCardForm {
  func refund(
    _ request: RefundRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    viewModel.refund(request, completion: completion)
  }

  func refund(
    _ request: RefundRequest
  ) async -> Result<PaymentResponse, SeamlessPayError> {
    await viewModel.refund(request)
  }
}

// MARK: - Internal
// MARK: - SingleLineCardForm ViewModel
extension SingleLineCardForm {
  var viewModel: CardFormViewModel {
    class_getInstanceVariable(
      type(of: self),
      "_viewModel"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? CardFormViewModel
    }!
  }
}
