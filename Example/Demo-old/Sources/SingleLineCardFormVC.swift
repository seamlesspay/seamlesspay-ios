/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import SeamlessPay

@objcMembers class SingleLineCardFormVC: UIViewController, CardFormDelegate {
  lazy var singleLineCardFormView: SingleLineCardForm = {
    let view = SingleLineCardForm(
      authorization: sharedSPAuthorization,
      fieldOptions: .init(
        cvv: .init(display: .required),
        postalCode: .init(display: .required)
      )
    )

    view.delegate = self

    return view
  }()

  lazy var payButton: UIButton = {
    let button = UIButton(type: .custom)
    button.layer.cornerRadius = 5
    button.backgroundColor = .gray
    button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    button.setTitle("Pay", for: .normal)
    button.addTarget(self, action: #selector(pay), for: .touchUpInside)
    button.isEnabled = false
    return button
  }()

  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.hidesWhenStopped = true
    return indicator
  }()

  lazy var resultLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.textColor = .black
    label.numberOfLines = 0
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    view.backgroundColor = .white
    let stackView = UIStackView(
      arrangedSubviews: [
        singleLineCardFormView,
        payButton,
        activityIndicator,
        resultLabel,
      ]
    )
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
    activityIndicator.startAnimating()

    singleLineCardFormView.submit(
      .init(amount: "101")
    ) { [weak self] result in

      self?.activityIndicator.stopAnimating()
      self?.resultLabel.text = ""

      switch result {
      case let .success(paymentResponse):
        // Success Charge:
        self?.resultLabel.text = "Payment Successful\n\(paymentResponse)"
      case let .failure(error):
        // Handle the error
        self?.resultLabel.text = "Payment Failed\n\(error.localizedDescription)"
        return
      }
    }
  }

  func cardFormDidChange(_ view: CardForm) {
    payButton.backgroundColor = view.isValid ? .systemBlue : .gray
    payButton.isEnabled = view.isValid
  }
}
