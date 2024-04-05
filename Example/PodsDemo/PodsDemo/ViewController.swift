// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import SeamlessPay

class ViewController: UIViewController {
  lazy var singleLineCardFormView: SingleLineCardForm = {
    let singleLineCardFormView = SingleLineCardForm(
      authorization: .init(environment: .sandbox, secretKey: "")
    )
    return singleLineCardFormView
  }()

  lazy var resultLabel: UILabel = {
    // Create Result Label
    let resultLabel = UILabel()
    resultLabel.textAlignment = .center
    resultLabel.numberOfLines = 0
    return resultLabel
  }()

  lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    view.backgroundColor = .white
    let stackView = UIStackView(arrangedSubviews: [singleLineCardFormView])
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)

    // Create Submit Button
    let submitButton = UIButton(type: .system)
    submitButton.setTitle("Submit", for: .normal)
    submitButton.addTarget(
      self,
      action: #selector(submitButtonTapped),
      for: .touchUpInside
    )
    stackView.addArrangedSubview(submitButton)

    stackView.addArrangedSubview(activityIndicator)
    stackView.addArrangedSubview(resultLabel)

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

  @objc func submitButtonTapped() {
    activityIndicator.startAnimating()
    resultLabel.isHidden = true
    singleLineCardFormView.submit(.init(amount: "101")) { result in
      self.activityIndicator.stopAnimating()
      self.resultLabel.isHidden = false
      self.resultLabel.text = "Result: \(result)"
    }
  }
}
