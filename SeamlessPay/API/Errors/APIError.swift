// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// Return code  Return description
// 01  Approval
// 02  Inactive Card
// 03  Invalid Card Number
// 04  Invalid Transaction Code
// 05  Insufficient Funds
// 06  No Previous Authorizations
// 07  Invalid Message
// 08  No Card Found
// 09  Insufficient Funds due to Outstanding Pre-Authorization
// 10  Denial - No Previous Authorization
// 11  No Authorization Number
// 12  Invalid Authorization Number
// 13  Maximum Single Recharge Exceeded
// 14  Maximum Working Balance Exceeded
// 15  Host Unavailable
// 16  Invalid Card Status
// 17  Unknown Dealer/Store Code – Special Edit
// 18  Maximum Number of Recharges Exceeded
// 19  Invalid Card Verification Value (CVV) or Secondary Security Code (SSC)
// 20  Invalid PIN Number or PIN Locked
// 21  Card Already Issued
// 22  Card Not Issued
// 23  Card Already Used
// 24  Manual Transaction Not Allowed
// 25  Mag Stripe Read not Valid
// 26  Transaction Type Unknown
// 27  Invalid Tender Type
// 28  Invalid Customer Type
// 29  Unknown Error
// 30  Max number of redemption exceeded
// 31  Invalid currency code
// 32  Invalid Server ID (restaurant only – server ID code is invalid)
// 33  Frozen card, contact customer service
// 34  Invalid Amount (Does not match the pre-valued card dollar amount)
// 35  Unknown Error, please contact customer support
// 36  Rejected – Invalid transaction promotion-wide or invalid for originating
// merchant and store
// 37  Rejected – Invalid merchant and store combination for promotion
// 38  Rejected – Exceeded maximum number of promotion cards allowed for a
// single POS transaction 42  Transaction declined – transaction amount less
// than the required minimum 99  Failure retrieving data (Enhance Balance Inquiry
// Only) 100  Card Number required 101  Merchant not found 102  Gift
// Card Processor not configured 103  Gift card not found 104  Type required
// 105  Amount required
// 106  Gift Card Processor not supported
// 107  Transaction cancelled
// 108  Transaction not found
// 109  Additional payment required to complete transaction

public struct APIError: LocalizedError {
  public let domain: String
  public let code: Int
  public let userInfo: [String: Any]

  public init(domain: String, code: Int, userInfo: [String: Any]) {
    self.domain = domain
    self.code = code
    self.userInfo = userInfo
  }

  public var errorDescription: String? {
    userInfo[NSLocalizedDescriptionKey] as? String
  }
}

extension APIError {
  static func apiError(_ data: Data) -> Self? {
    guard let json = try? JSONSerialization.jsonObject(
      with: data,
      options: .allowFragments
    ) as? [String: Any] else {
      return nil
    }

    return .init(
      domain: "api.seamlesspay.com",
      code: json["code"] as? Int ?? 0,
      userInfo: [
        NSLocalizedDescriptionKey: description(json),
      ]
    )
  }

  private static func description(_ dictionary: [String: Any]) -> String {
    var output = [String]()
    output.append(dictionary.stringFor("name"))
    output.append(dictionary.stringFor("message"))
    output.append(dictionary.stringFor("className"))
    if let data = dictionary["data"] as? [String: Any] {
      output.append(data.stringFor("statusCode"))
      output.append(data.stringFor("statusDescription"))
    }
    output.append(dictionary.stringFor("errors"))

    return output.joined(separator: "\n")
  }
}

private extension [String: Any] {
  func stringFor(_ key: String) -> String {
    return "\(key.capitalized)=\(self[key] ?? "")"
  }
}
