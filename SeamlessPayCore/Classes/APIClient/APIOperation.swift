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
  case voidCharge(id: String)

  private var pathBase: String {
    switch self {
    case .createToken:
      return "tokens"
    case .createCustomer,
         .retrieveCustomer,
         .updateCustomer:
      return "customers"
    case .createCharge,
         .listCharges,
         .retrieveCharge,
         .voidCharge:
      return "charges"
    case .createRefund:
      return "refunds"
    }
  }

  var path: String {
    var path = "/" + pathBase
    switch self {
    case let .retrieveCharge(value),
         let .retrieveCustomer(value),
         let .updateCustomer(value),
         let .voidCharge(value):
      path += "/" + value
    default:
      break
    }

    return path
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
    case .voidCharge:
      return .delete
    }
  }
}
