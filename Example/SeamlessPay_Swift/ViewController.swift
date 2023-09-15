/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

import PassKit
import SeamlessPayCore

class ViewController: UIViewController {
  lazy var cardTextField: SPPaymentCardTextField = {
    let cardTextField = SPPaymentCardTextField()
    return cardTextField
  }()

  lazy var payButton: UIButton = {
    let button = UIButton(type: .custom)
    button.layer.cornerRadius = 5
    button.backgroundColor = .systemBlue
    button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    button.setTitle("Pay", for: .normal)
    button.addTarget(self, action: #selector(pay), for: .touchUpInside)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    view.backgroundColor = .white
    let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.leftAnchor.constraint(
        equalToSystemSpacingAfter: view.leftAnchor,
        multiplier: 2
      ),
      view.rightAnchor.constraint(
        equalToSystemSpacingAfter: stackView.rightAnchor,
        multiplier: 2
      ),
      stackView.topAnchor.constraint(
        equalToSystemSpacingBelow: view.topAnchor,
        multiplier: 20
      ),
    ])
  }

  @objc
  func pay() {
    let billingAddress = SPAddress(
      line1: nil,
      line2: nil,
      city: nil,
      country: nil,
      state: nil,
      postalCode: cardTextField.postalCode
    )

    APIClient.shared.tokenize(
      paymentType: .creditCard,
      accountNumber: cardTextField.cardNumber ?? .init(),
      expDate: cardTextField.formattedExpirationDate,
      cvv: cardTextField.cvc,
      billingAddress: billingAddress,
      name: "Michael Smith"
    ) { result in
      switch result {
      case let .success(paymentMethod):
        let token = paymentMethod.token

        APIClient.shared.createCharge(
          token: token!,
          cvv: self.cardTextField.cvc,
          capture: true,
          amount: "1",
          taxExempt: false
        ) { result in
          switch result {
          case let .success(charge):
            // Success Charge:
            print(charge.chargeId ?? "charge is nil")
          case let .failure(error):
            // Handle the error
            print(error.localizedDescription)
            return
          }
        }
      case let .failure(error):
        // Handle the error
        print(error.localizedDescription)
      }
    }
  }
}
