// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public class MultiLineCardForm: CardForm {
  // MARK: Subviews
  private var numberField: SPFormTextField {
    getInstanceVariable("_numberField")!
  }

  private var expirationField: SPFormTextField {
    getInstanceVariable("_expirationField")!
  }

  private var cvcField: SPFormTextField {
    getInstanceVariable("_cvcField")!
  }

  private var postalCodeField: SPFormTextField {
    getInstanceVariable("_postalCodeField")!
  }

  private var fieldsView: UIView {
    getInstanceVariable("_fieldsView")!
  }

  private var boundedView: UIView {
    getInstanceVariable("_boundedView")!
  }

  private var brandImageView: UIImageView {
    getInstanceVariable("_brandImageView")!
  }

  private lazy var cardNumberLabel = buildHeaderLabel(placeholder: "Card Number")
  private lazy var expirationDateLabel = buildHeaderLabel(placeholder: "Exp Date")
  private lazy var cvcLabel = buildHeaderLabel(placeholder: "Security Code")
  private lazy var postalCodeLabel = buildHeaderLabel(placeholder: "ZIP Code")

  // MARK: Private variables
  private lazy var headerLabels: [UILabel] = [
    cardNumberLabel,
    expirationDateLabel,
    cvcLabel,
    postalCodeLabel,
  ]
  private var postalCodeFieldHeightConstraint: NSLayoutConstraint?
  private var fieldsViewBottomConstraint: NSLayoutConstraint?

  // MARK: Override
  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  override public func setCVCDisplayConfig(_ displayConfig: CardFieldDisplay) {
    super.setCVCDisplayConfig(displayConfig)

    let cvcShouldBeHidden = displayConfig == .none
    cvcField.isHidden = cvcShouldBeHidden
    cvcLabel.isHidden = cvcShouldBeHidden

    layoutIfNeeded()
  }

  override public func setPostalCodeDisplayConfig(_ displayConfig: CardFieldDisplay) {
    super.setPostalCodeDisplayConfig(displayConfig)

    let postalCodeShouldBeHidden = displayConfig == .none
    fieldsViewBottomConstraint?.isActive = false
    let bottomAnchor =
      postalCodeShouldBeHidden ? expirationField.bottomAnchor : postalCodeField.bottomAnchor

    fieldsViewBottomConstraint = fieldsView.bottomAnchor.constraint(
      equalTo: bottomAnchor,
      constant: -0
    )
    fieldsViewBottomConstraint?.isActive = true

    postalCodeField.isHidden = postalCodeShouldBeHidden
    postalCodeLabel.isHidden = postalCodeShouldBeHidden

    layoutIfNeeded()
  }

  // MARK: Private
  private func commonInit() {
    addSubview(boundedView)

    boundedView.addSubview(fieldsView)

    fieldsView.addSubview(numberField)
    fieldsView.addSubview(expirationField)
    fieldsView.addSubview(cvcField)
    fieldsView.addSubview(postalCodeField)

    configureViews()
    constraintViews()
  }
}

// MARK: Set Up Views
private extension MultiLineCardForm {
  func configureViews() {
    numberField.borderStyle = .roundedRect
    expirationField.borderStyle = .roundedRect
    cvcField.borderStyle = .roundedRect
    postalCodeField.borderStyle = .roundedRect

    numberField.placeholder = "1234 1234 1234 1234"
    cvcField.placeholder = "***"
    postalCodeField.placeholder = "12345"

    numberField.rightView = brandImageView
    numberField.rightViewMode = .always
  }

  // swiftlint:disable function_body_length
  func constraintViews() {
    let offset1: CGFloat = 10
    let offset2: CGFloat = 15
    let offset3: CGFloat = 30

    boundedView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        boundedView.centerYAnchor.constraint(equalTo: centerYAnchor),
        boundedView.centerXAnchor.constraint(equalTo: centerXAnchor),
        boundedView.heightAnchor.constraint(equalTo: fieldsView.heightAnchor, constant: offset3),
      ]
    )

    let equalWidthConstraint = boundedView.widthAnchor.constraint(equalTo: widthAnchor)
    equalWidthConstraint.priority = .defaultHigh
    equalWidthConstraint.isActive = true

    let minWidthConstraint = boundedView.widthAnchor.constraint(
      greaterThanOrEqualTo: fieldsView.widthAnchor,
      constant: offset3
    )
    minWidthConstraint.priority = .required
    minWidthConstraint.isActive = true

    fieldsView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        fieldsView.centerXAnchor.constraint(equalTo: boundedView.centerXAnchor),
        fieldsView.centerYAnchor.constraint(equalTo: boundedView.centerYAnchor),
      ]
    )

    fieldsViewBottomConstraint = fieldsView.bottomAnchor.constraint(
      equalTo: postalCodeField.bottomAnchor,
      constant: -0
    )

    fieldsViewBottomConstraint?.isActive = true

    fieldsView.addSubview(cardNumberLabel)

    NSLayoutConstraint.activate(
      [
        cardNumberLabel.topAnchor.constraint(equalTo: fieldsView.topAnchor, constant: 0),
        cardNumberLabel.leadingAnchor.constraint(
          equalTo: numberField.leadingAnchor,
          constant: 0
        ),
        cardNumberLabel.trailingAnchor.constraint(
          equalTo: numberField.trailingAnchor,
          constant: 0
        ),
      ]
    )

    numberField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        numberField.topAnchor.constraint(equalTo: cardNumberLabel.bottomAnchor, constant: offset1),
        numberField.leadingAnchor.constraint(
          equalTo: fieldsView.leadingAnchor,
          constant: offset1
        ),
        numberField.trailingAnchor.constraint(
          equalTo: fieldsView.trailingAnchor,
          constant: -offset1
        ),
        numberField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    fieldsView.addSubview(expirationDateLabel)

    NSLayoutConstraint.activate(
      [
        expirationDateLabel.topAnchor.constraint(
          equalTo: numberField.bottomAnchor,
          constant: offset2
        ),
        expirationDateLabel.leadingAnchor.constraint(
          equalTo: expirationField.leadingAnchor,
          constant: 0
        ),
        expirationDateLabel.trailingAnchor.constraint(
          equalTo: expirationField.trailingAnchor,
          constant: 0
        ),
      ]
    )

    expirationField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        expirationField.topAnchor.constraint(
          equalTo: expirationDateLabel.bottomAnchor,
          constant: offset1
        ),
        expirationField.leadingAnchor.constraint(
          equalTo: fieldsView.leadingAnchor,
          constant: offset1
        ),
        expirationField.trailingAnchor.constraint(
          equalTo: cvcField.leadingAnchor,
          constant: -offset1
        ),
        expirationField.widthAnchor.constraint(equalTo: cvcField.widthAnchor, multiplier: 1.5),
        expirationField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    fieldsView.addSubview(cvcLabel)

    NSLayoutConstraint.activate(
      [
        cvcLabel.centerYAnchor.constraint(equalTo: expirationDateLabel.centerYAnchor),
        cvcLabel.leadingAnchor.constraint(
          equalTo: cvcField.leadingAnchor,
          constant: 0
        ),
        cvcLabel.trailingAnchor.constraint(
          equalTo: cvcField.trailingAnchor,
          constant: 0
        ),
      ]
    )

    cvcField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        cvcField.centerYAnchor.constraint(equalTo: expirationField.centerYAnchor),
        cvcField.trailingAnchor.constraint(equalTo: fieldsView.trailingAnchor, constant: -offset1),
        cvcField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    fieldsView.addSubview(postalCodeLabel)

    NSLayoutConstraint.activate([
      postalCodeLabel.topAnchor.constraint(equalTo: cvcField.bottomAnchor, constant: offset2),
      postalCodeLabel.leadingAnchor.constraint(
        equalTo: postalCodeField.leadingAnchor,
        constant: 0
      ),
      postalCodeLabel.trailingAnchor.constraint(
        equalTo: postalCodeField.trailingAnchor,
        constant: 0
      ),
    ])

    postalCodeField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        postalCodeField.topAnchor.constraint(
          equalTo: postalCodeLabel.bottomAnchor,
          constant: offset1
        ),
        postalCodeField.leadingAnchor.constraint(
          equalTo: fieldsView.leadingAnchor,
          constant: offset1
        ),
        postalCodeField.heightAnchor.constraint(equalToConstant: 44),
        postalCodeField.widthAnchor.constraint(equalTo: expirationField.widthAnchor),
      ]
    )
  }
  // swiftlint:enable function_body_length
}

private extension MultiLineCardForm {
  func buildHeaderLabel(placeholder: String) -> UILabel {
    let label = UILabel()
    label.text = placeholder
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 14)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }
}

// MARK: Get Instance Variable
private extension MultiLineCardForm {
  func getInstanceVariable<T>(_ propertyName: String) -> T? {
    class_getInstanceVariable(
      type(of: self),
      propertyName
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? T
    }
  }
}
