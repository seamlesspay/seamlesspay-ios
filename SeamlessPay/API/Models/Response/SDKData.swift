// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

struct SDKData: APICodable {
  let applePay: MerchantConfig?
  let googlePay: MerchantConfig?
  let seamlessPay: SeamlessPayConfig

  enum CodingKeys: String, CodingKey {
    case applePay = "ApplePay"
    case googlePay = "GooglePay"
    case seamlessPay = "SeamlessPay"
  }

  struct MerchantConfig: APICodable {
    let merchantId: String

    enum CodingKeys: String, CodingKey {
      case merchantId = "MerchantId"
    }
  }

  struct SeamlessPayConfig: APICodable {
    let merchantName: String

    enum CodingKeys: String, CodingKey {
      case merchantName = "MerchantName"
    }
  }
}
