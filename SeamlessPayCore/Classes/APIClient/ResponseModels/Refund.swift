// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

// MARK: - Refund
public class Refund: APICodable {
  public let accountType: String?
  public let amount: String?
  public let authCode: String?
  public let batchID: String?
  public let createdAt: String?
  public let currency: String?
  public let events: [Event]?
  public let id: String?
  public let idempotencyKey: String?
  public let ipAddress: String?
  public let lastFour: String?
  public let metadata: String?
  public let method: String?
  public let paymentNetwork: String?
  public let status: String?
  public let statusCode: String?
  public let statusDescription: String?
  public let token: String?
  public let transactionDate: Date?
  public let updatedAt: String?

  enum CodingKeys: String, CodingKey {
    case accountType
    case amount
    case authCode
    case batchID = "batchId"
    case createdAt
    case currency
    case events
    case id
    case idempotencyKey
    case ipAddress
    case lastFour
    case metadata
    case method
    case paymentNetwork
    case status
    case statusCode
    case statusDescription
    case token
    case transactionDate
    case updatedAt
  }
}
