// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

enum APIOperation {
  case createToken
  case createCustomer
  case updateCustomer(id: String)
  case retrieveCustomer(id: String)
  case createCharge
  case retrieveCharge(id: String)
  case listCharges
  case createRefund

  var path: String {
    let body: String
    switch self {
    case .createToken:
      body = "tokens"
    case .createCustomer:
      body = "customers"
    case let .retrieveCharge(value),
         let .retrieveCustomer(value),
         let .updateCustomer(value):
      body = ["customers", value].joined(separator: "/")
    case .createCharge,
         .listCharges:
      body = "charges"
    case .createRefund:
      body = "refunds"
    }
    return "/" + body
  }

  var method: HTTPMethod {
    switch self {
    case .createCharge,
         .createCustomer,
         .createToken,
         .createRefund:
      return .post
    case .updateCustomer:
      return .put
    case .listCharges,
         .retrieveCharge,
         .retrieveCustomer:
      return .get
    }
  }
}
