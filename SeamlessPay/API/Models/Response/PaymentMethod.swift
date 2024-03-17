// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - PaymentMethod

/**
 *  A token returned from submitting payment details to the SeamlessPay API. You
 *  should not have to instantiate one of these directly.
 */
public struct PaymentMethod: APICodable {
  /**
   *  Token of given payment data.
   */
  public let token: String
  /**
   *  Expiration Date.
   */
  public let expDate: String?
  /**
   *  Last four of account number.
   */
  public let lastFour: String?
  /**
   *  Name as it appears on card..
   */
  public let name: String?
  /**
   *  The various card brands to which a payment card can belong.
   */
  public let paymentNetwork: PaymentNetwork?
  /**
   *  PAN Vault support five types of payments "Credit Card", "PINLess Debit
   *  Card", "ACH", "Gift Card" enum: credit_card, pldebit_card, ach, gift_card
   */
  public let paymentType: PaymentType?
  /**
   *  Bank account type: "Checking" "Savings"
   */
  public let bankAccountType: String?
  /**
   *  Bank routing number
   */
  public let routingNumber: String?
  /**
   Verification (Dictionary):

   avsStreetAddress =>  (string) "pass" "fail" "unchecked" "unsupported" "retry"
   AVS Verification Code (See all AVS verification codes)

   avsPostalCode => ( string)  "pass" "fail" "unchecked" "unsupported" "retry"
   AVS Verification Code (See all AVS verification codes)

   cvv => (string) "pass" "fail" "unchecked" "unsupported" "retry"
   CVV Verification Code (See all CVV verification codes)
   */
  public let verificationResults: VerificationResults?

  public let billingAddress: Address?
}
