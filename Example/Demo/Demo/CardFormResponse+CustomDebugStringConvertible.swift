// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SeamlessPay

extension PaymentMethodResponse: CustomDebugStringConvertible {
  public var debugDescription: String {
    """
    Payment Method Response:
      - Payment Token: \(paymentToken)
      - Payment Type: \(paymentType.rawValue)
      - Details:
          - Name: \(details.name ?? "N/A")
          - Last Four: \(details.lastFour ?? "N/A")
          - Expiration Date: \(details.expirationDate ?? "N/A")
          - Payment Network: \(details.paymentNetwork?.rawValue ?? "N/A")
    """
  }
}

extension RefundResponse: CustomDebugStringConvertible {
  public var debugDescription: String {
    """
    Refund Response:
      - ID: \(id)
      - Payment Method: \(paymentMethod.debugDescription)
      - Details:
          - Amount: \(details.amount ?? "N/A")
          - Auth Code: \(details.authCode ?? "N/A")
          - Batch ID: \(details.batchId ?? "N/A")
          - Last Four: \(details.lastFour ?? "N/A")
          - Card Brand: \(details.cardBrand?.rawValue ?? "N/A")
          - Status: \(details.status?.rawValue ?? "N/A")
          - Status Code: \(details.statusCode ?? "N/A")
          - Status Description: \(details.statusDescription ?? "N/A")
          - Transaction Date: \(details.transactionDate ?? "N/A")
    """
  }
}

extension ChargeResponse: CustomDebugStringConvertible {
  public var debugDescription: String {
    """
    Payment Response:
      - ID: \(id)
      - Payment Method: \(paymentMethod.debugDescription)
      - Details:
          - Amount: \(details.amount ?? "N/A")
          - Auth Code: \(details.authCode ?? "N/A")
          - Batch ID: \(details.batchId ?? "N/A")
          - Last Four: \(details.lastFour ?? "N/A")
          - Card Brand: \(details.cardBrand?.rawValue ?? "N/A")
          - Status: \(details.status?.rawValue ?? "N/A")
          - Status Code: \(details.statusCode ?? "N/A")
          - Status Description: \(details.statusDescription ?? "N/A")
          - Surcharge Fee Amount: \(details.surchargeFeeAmount ?? "N/A")
          - Transaction Date: \(details.transactionDate ?? "N/A")
    """
  }
}
