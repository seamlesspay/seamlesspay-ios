// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Charge

public struct Charge: APICodable {
  /**
   * The ID of base charge.
   */
  public let id: String
  /**
   * Value: "charge"  Transaction method
   */
  public let method: String?
  /**
   * Amount to add to stored value account.
   */
  public let amount: String?
  /**
   * String with 2 decimal places e.g “25.00”.
   */
  public let tip: String?
  /**
   * Surcharge fee amount. String with 2 decimal places e.g “25.00”.
   */
  public let surchargeFeeAmount: String?
  /**
   * Order dictionary
   */
  public let order: Order?
  /**
   * Currency:  USD - United States dollar.  CAD - Canadian dollar.
   */
  public let currency: String?
  /**
   * Card Expiration Date.
   */
  public let expDate: String?
  /**
   * Last four of account number.
   */
  public let lastFour: String?
  /**
   * The payment method (token) from pan-vault
   */
  public let token: String?
  /**
   * Transaction date string <date-time>
   */
  public let transactionDate: String?
  /**
   * Enum: "authorized" "captured" "declined" "error"  Transaction status
   */
  public let status: String?
  /**
   * Transaction status code
   * (See all available transaction status codes https://docs.seamlesspay.com/#section/Transaction-Statuses ).
   */
  public let statusCode: String?
  /**
   * Transaction status description.
   */
  public let statusDescription: String?
  /**
   * IP address
   */
  public let ipAddress: String?
  /**
   * Auth Code
   */
  public let authCode: String?
  /**
   * Enum: "Credit" "Debit" "Prepaid".
   * Determines the card type (credit, debit, prepaid) and usage (pin, signature etc.).
   */
  public let accountType: String?
  /**
   * Payment type
   */
  public let paymentType: String?
  /**
   * Enum: "Visa" "MasterCard" "American Express" "Discover".
   * Detail Card Product - Visa, MasterCard, American Express, Discover.
   */
  public let paymentNetwork: String?
  /**
   * Batch ID
   */
  public let batch: String?
  /**
    *  verificationResults
   */
  public let verificationResults: VerificationResults?
  /**
    *  Business Card
   */
  public let businessCard: Bool?
  /**
    *  fullyRefunded
   */
  public let fullyRefunded: Bool?
  /**
    *  Array of Dictionary  List of refunds associated with the charge.
   */
  public let refunds: [Refund]?
  /**
   *   The customer's created.
   *   string <date-time>
   */
  public let createdAt: String?
  /**
   *   The customer's updated.
   *   string <date-time>
   */
  public let updatedAt: String?
}

// MARK: - Order
public struct Order: Codable {
  public let items: [Item]?
  public let shipFromPostalCode: String?
  public let shippingAddress: Address?
}

// MARK: - Item
public struct Item: Codable {
  public let itemDescription, discountAmount, lineNumber, lineTotal: String?
  public let taxRate, unitCost, unitOfMeasure, upc: String?
  public let quantity, taxAmount: String?
  public let taxExempt: Bool?

  enum CodingKeys: String, CodingKey {
    case itemDescription = "description"
    case discountAmount
    case lineNumber
    case lineTotal
    case quantity
    case taxAmount
    case taxExempt
    case taxRate
    case unitCost
    case unitOfMeasure
    case upc
  }
}

// MARK: - VerificationResults
public struct VerificationResults: Codable {
  public let avsPostalCode, avsStreetAddress, cvv: String?
}
