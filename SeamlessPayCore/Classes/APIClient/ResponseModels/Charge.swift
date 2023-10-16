// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Charge

public class Charge: NSObject, APICodable {
  public let id, method, amount, tip, surchargeFeeAmount: String?
  public let order: Order?
  public let currency, expDate, lastFour, token, transactionDate: String?
  public let status, statusCode, statusDescription, ipAddress: String?
  public let authCode, accountType, paymentType, paymentNetwork, batch: String?
  public let verificationResults: VerificationResults?
  public let businessCard: Bool?
  public let fullyRefunded: Bool?
  public let refunds: [Refund]?
  public let createdAt, updatedAt: String?

  public init(
    id: String? = nil,
    method: String? = nil,
    amount: String? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    order: Order? = nil,
    currency: String? = nil,
    expDate: String? = nil,
    lastFour: String? = nil,
    token: String? = nil,
    transactionDate: String? = nil,
    status: String? = nil,
    statusCode: String? = nil,
    statusDescription: String? = nil,
    ipAddress: String? = nil,
    authCode: String? = nil,
    accountType: String? = nil,
    paymentType: String? = nil,
    paymentNetwork: String? = nil,
    batch: String? = nil,
    verificationResults: VerificationResults? = nil,
    businessCard: Bool? = nil,
    fullyRefunded: Bool? = nil,
    refunds: [Refund]? = nil,
    createdAt: String? = nil,
    updatedAt: String? = nil
  ) {
    self.id = id
    self.method = method
    self.amount = amount
    self.tip = tip
    self.surchargeFeeAmount = surchargeFeeAmount
    self.order = order
    self.currency = currency
    self.expDate = expDate
    self.lastFour = lastFour
    self.token = token
    self.transactionDate = transactionDate
    self.status = status
    self.statusCode = statusCode
    self.statusDescription = statusDescription
    self.ipAddress = ipAddress
    self.authCode = authCode
    self.accountType = accountType
    self.paymentType = paymentType
    self.paymentNetwork = paymentNetwork
    self.batch = batch
    self.verificationResults = verificationResults
    self.businessCard = businessCard
    self.fullyRefunded = fullyRefunded
    self.refunds = refunds
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

// MARK: - Order
public class Order: NSObject, Codable {
  public let items: [Item]?
  public let shipFromPostalCode: String?
  public let shippingAddress: ShippingAddress?

  public init(
    items: [Item]? = nil,
    shipFromPostalCode: String? = nil,
    shippingAddress: ShippingAddress? = nil
  ) {
    self.items = items
    self.shipFromPostalCode = shipFromPostalCode
    self.shippingAddress = shippingAddress
  }
}

// MARK: - Item
public class Item: NSObject, Codable {
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

  public init(
    itemDescription: String? = nil,
    discountAmount: String? = nil,
    lineNumber: String? = nil,
    lineTotal: String? = nil,
    quantity: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    taxRate: String? = nil,
    unitCost: String? = nil,
    unitOfMeasure: String? = nil,
    upc: String? = nil
  ) {
    self.itemDescription = itemDescription
    self.discountAmount = discountAmount
    self.lineNumber = lineNumber
    self.lineTotal = lineTotal
    self.quantity = quantity
    self.taxAmount = taxAmount
    self.taxExempt = taxExempt
    self.taxRate = taxRate
    self.unitCost = unitCost
    self.unitOfMeasure = unitOfMeasure
    self.upc = upc
  }
}

// MARK: - ShippingAddress
public class ShippingAddress: NSObject, Codable {
  public let city, country, line1, line2, postalCode, state: String?

  public init(
    city: String? = nil,
    country: String? = nil,
    line1: String? = nil,
    line2: String? = nil,
    postalCode: String? = nil,
    state: String? = nil
  ) {
    self.city = city
    self.country = country
    self.line1 = line1
    self.line2 = line2
    self.postalCode = postalCode
    self.state = state
  }
}

// MARK: - VerificationResults
public class VerificationResults: NSObject, Codable {
  public let avsPostalCode, avsStreetAddress, cvv: String?

  public init(avsPostalCode: String? = nil, avsStreetAddress: String? = nil, cvv: String? = nil) {
    self.avsPostalCode = avsPostalCode
    self.avsStreetAddress = avsStreetAddress
    self.cvv = cvv
  }
}
