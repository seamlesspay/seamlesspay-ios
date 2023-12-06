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
