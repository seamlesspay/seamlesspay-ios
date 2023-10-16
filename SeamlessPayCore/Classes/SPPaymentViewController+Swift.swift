// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

extension SPPaymentViewController {
  @objc func pay() {

    paymentAmount = amountTextField.text.flatMap {
      $0.dropFirst()
      .replacingOccurrences(of: ",", with: "")
    }

    activityIndicator.startAnimation()

    APIClient.shared.tokenize(
      paymentType: .init(rawValue: paymentType.rawValue) ?? .creditCard,
      accountNumber: cardTextField.cardNumber ?? "",
      expDate: .init(month: cardTextField.expirationMonth, year: cardTextField.expirationYear),
      cvv: cardTextField.cvc,
      accountType: nil,
      routing: nil,
      pin: nil,
      billingAddress: billingAddress,
      name: name
    ) { result in
      DispatchQueue.main.async {
        switch result {
        case let .success(paymentMethod):
          if let delegate = self.delegate,
             delegate.responds(
               to: #selector(delegate.paymentViewController(_:paymentMethodSuccess:))
             ) {
            delegate.paymentViewController?(self, paymentMethodSuccess: paymentMethod)
          }

          APIClient.shared.createCharge(
            token: paymentMethod.token,
            cvv: self.cardTextField.cvc,
            capture: true,
            currency: nil,
            amount: self.paymentAmount,
            taxAmount: nil,
            taxExempt: false,
            tip: nil,
            surchargeFeeAmount: nil,
            description: self.paymentDescription,
            order: nil,
            orderID: self.orderId,
            poNumber: nil,
            metadata: self.paymentMetadata,
            descriptor: nil,
            entryType: nil,
            idempotencyKey: self.idempotencyKey
          ) { result in
            self.activityIndicator.stopAnimation()
            switch result {
            case let .success(charge):
              if let delegate = self.delegate,
                 delegate.responds(
                   to: #selector(delegate.paymentViewController(_:chargeSuccess:))
                 ) {
                delegate.paymentViewController(self, chargeSuccess: charge)
              }
            case let .failure(error):
              if let delegate = self.delegate,
                 delegate.responds(
                   to: #selector(delegate.paymentViewController(_:chargeError:))
                 ) {
                delegate.paymentViewController(self, chargeError: error.spError)
              }
            }
          }
        case let .failure(error):
          self.activityIndicator.stopAnimation()
          if let delegate = self.delegate,
             delegate
             .responds(
               to: #selector(delegate.paymentViewController(_:paymentMethodError:))
             ) {
            delegate.paymentViewController(self, paymentMethodError: error.spError)
          }
        }
      }
    }
  }
}
