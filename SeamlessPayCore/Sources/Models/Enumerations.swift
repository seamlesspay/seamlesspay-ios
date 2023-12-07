// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public enum AccountType: String, APICodable {
  case credit = "Credit"
  case debit = "Debit"
  case prepaid = "Prepaid"
}

public enum Currency: String, APICodable {
  case usd = "USD"
  case cad = "CAD"
}

public enum Status: String, APICodable {
  case authorized
  case captured
  case declined
  case error
  case settled
  case voided
}

public enum Method: String, APICodable {
  case refund
  case charge
}

public enum PaymentNetwork: String, APICodable {
  case visa = "Visa"
  case masterCard = "MasterCard"
  case americanExpress = "American Express"
  case discover = "Discover"
}

public enum AVSResult: String, APICodable {
  case pass
  case fail
  case unchecked
  case unsupported
  case retry
}
