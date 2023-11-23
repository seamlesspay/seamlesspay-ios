// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Address
public struct Address {
  public let line1: String?
  public let line2: String?
  public let country: String?
  public let state: String?
  public let city: String?
  public let postalCode: String?

  public init(
    line1: String?,
    line2: String?,
    country: String?,
    state: String?,
    city: String?,
    postalCode: String?
  ) {
    self.city = city
    self.country = country
    self.line1 = line1
    self.line2 = line2
    self.postalCode = postalCode
    self.state = state
  }
}

extension Address: APICodable, APIReqParameterable {}

// MARK: - SPAddress compatibility
//public extension Address {
//  init(spAddress: SPAddress) {
//    city = spAddress.city
//    country = spAddress.country
//    line1 = spAddress.line1
//    line2 = spAddress.line2
//    postalCode = spAddress.postalCode
//    state = spAddress.state
//  }
//
//  var spAddress: SPAddress {
//    let spAddress = SPAddress()
//    spAddress.city = city
//    spAddress.country = country
//    spAddress.line1 = line1
//    spAddress.line2 = line2
//    spAddress.postalCode = postalCode
//    spAddress.state = state
//    return spAddress
//  }
//}

//public extension Address {
//  static func shippingInfoForCharge(
//    address: Address,
//    shippingMethod: PKShippingMethod
//  ) -> [String: Any]? {
//    var params = [String: Any]()
//    params["carrier"] = shippingMethod.label
//    params["address"] = SPFormEncoder.dictionary(
//      forObject: address.spAddress
//    )
//
//    return params
//  }
//
//  init?(billingDetails: SPPaymentMethodBillingDetails) {
//    guard let pmAddress = billingDetails.address else {
//      return nil
//    }
//    line1 = pmAddress.line1
//    line2 = pmAddress.line2
//    city = pmAddress.city
//    state = pmAddress.state
//    postalCode = pmAddress.postalCode
//    country = pmAddress.country
//  }
//
//  init?(contact: CNContact) {
//    guard let postalAddress = contact.postalAddresses.first?.value else { return nil }
//    line1 = postalAddress.street
//    line2 = nil
//    city = postalAddress.city
//    state = postalAddress.state
//    postalCode = postalAddress.postalCode
//    country = postalAddress.isoCountryCode.uppercased()
//  }
//
//  func pkContactValue() -> PKContact {
//    let contact = PKContact()
//
//    let address = CNMutablePostalAddress()
//    address.street = [
//      line1,
//      line2,
//    ]
//    .compactMap { $0 }
//    .joined(separator: " ")
//    address.city = city ?? ""
//    address.state = state ?? ""
//    address.postalCode = postalCode ?? ""
//    address.country = country ?? ""
//
//    contact.postalAddress = address
//
//    return contact
//  }
//
//  func containsRequiredFields(_ requiredFields: SPBillingAddressFields) -> Bool {
//    switch requiredFields {
//    case .none:
//      return true
//    case .zip:
//      return SPPostalCodeValidator.validationState(
//        forPostalCode: postalCode,
//        countryCode: country
//      ) == .valid
//    case .full:
//      return hasValidPostalAddress
//    case .name:
//      return false
//    @unknown default:
//      return false
//    }
//  }
//
//  private var hasValidPostalAddress: Bool {
//    guard let line1, let city, let country, let state else {
//      return false
//    }
//    return
//      !line1.isEmpty &&
//      !city.isEmpty &&
//      !country.isEmpty &&
//      (!state.isEmpty || country != "US") &&
//      SPPostalCodeValidator
//      .validationState(forPostalCode: postalCode, countryCode: country) == .valid
//  }
//
//  func containsContentForBillingAddressFields(_ desiredFields: SPBillingAddressFields) -> Bool {
//    switch desiredFields {
//    case .none:
//      return false
//    case .zip:
//      if let postalCode {
//        return !postalCode.isEmpty
//      }
//      return false
//    case .full:
//      return hasPartialPostalAddress
//    case .name:
//      return false
//    @unknown default:
//      return false
//    }
//  }
//
//  private var hasPartialPostalAddress: Bool {
//    guard let line1, let line2, let city, let country, let state else {
//      return false
//    }
//
//    return [
//      line1,
//      line2,
//      city,
//      country,
//      state,
//    ]
//    .contains { !$0.isEmpty }
//  }
//
//  func containsRequiredShippingAddressFields(_ requiredFields: Set<SPContactField>) -> Bool {
//    var containsFields = true
//
//    if requiredFields.contains(.postalAddress) {
//      containsFields = containsFields && hasValidPostalAddress
//    }
//
//    return containsFields
//  }
//}
