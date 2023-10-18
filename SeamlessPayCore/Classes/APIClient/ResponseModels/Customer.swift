// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Customer
public struct Customer: APICodable {
  /**
   * Unique identifier for the object.
   */
  public let id: String
  /**
   * The customer's first address
   */
  public let address: Address?
  /**
   *  The customer's company name.
   */
  public let companyName: String?
  /**
   *  The customer's description.
   */
  public let description: String?
  /**
   * Customer email.
   */
  public let email: String?
  /**
   *  Custom json object
   */
  public let metadata: String?
  /**
   * The customer's name.
   */
  public let name: String?
  /**
   *  The customer's payment methods.
   *  Array of type PaymentMethod
   */
  public let paymentMethods: [PaymentMethod]?
  /**
   *   The customer's phone number.
   */
  public let phone: String?
  /**
   *   The customer's website.
   */
  public let website: String?
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

// MARK: - Address
public struct Address: Codable {
  public let city, country, line1, line2: String?
  public let postalCode, state: String?
}
