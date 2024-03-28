/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

import PassKit
import SeamlessPay

@objcMembers class SPPaymentCardTextFieldSwift: UIViewController {
  lazy var cardTextField = SPPaymentCardTextField(
    authorization: sharedSPAuthorization
  )

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

  func pay() {
    let billingAddress = Address(
      line1: nil,
      line2: nil,
      country: nil,
      state: nil,
      city: nil,
      postalCode: cardTextField.postalCode
    )

    cardTextField.submit(
      amount: "1"
    ) { result in
      switch result {
      case let .success(paymentResponse):
        // Success Charge:
        print(paymentResponse)
      case let .failure(error):
        // Handle the error
        print(error.localizedDescription)
        return
      }
    }
  }
}
