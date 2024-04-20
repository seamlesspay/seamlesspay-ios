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

  private var brandImageView: UIImageView {
    getInstanceVariable("_brandImageView")!
  }

  // MARK: Override
  override public func commonInit() {
    super.commonInit()

    constraintViews()
  }
}

// MARK: Set Up Views
private extension MultiLineCardForm {
  func constraintViews() {
    fieldsView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        fieldsView.centerYAnchor.constraint(equalTo: centerYAnchor),
        fieldsView.centerXAnchor.constraint(equalTo: centerXAnchor),
        fieldsView.widthAnchor.constraint(equalTo: widthAnchor),
      ]
    )

    numberField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        numberField.topAnchor.constraint(equalTo: fieldsView.topAnchor, constant: 0),
        numberField.leadingAnchor.constraint(
          equalTo: fieldsView.leadingAnchor,
          constant: 10
        ),
        numberField.trailingAnchor.constraint(
          equalTo: fieldsView.trailingAnchor,
          constant: -44
        ),
        numberField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    brandImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        brandImageView.trailingAnchor.constraint(
          equalTo: fieldsView.trailingAnchor,
          constant: -10
        ),
        brandImageView.centerYAnchor.constraint(equalTo: numberField.centerYAnchor),
      ]
    )

    expirationField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        expirationField.topAnchor.constraint(equalTo: numberField.bottomAnchor, constant: 10),
        expirationField.leadingAnchor.constraint(equalTo: fieldsView.leadingAnchor, constant: 10),
        expirationField.trailingAnchor.constraint(equalTo: cvcField.leadingAnchor, constant: -10),
        expirationField.widthAnchor.constraint(equalTo: cvcField.widthAnchor, multiplier: 1.5),
        expirationField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    cvcField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        cvcField.topAnchor.constraint(equalTo: expirationField.topAnchor),
        cvcField.trailingAnchor.constraint(equalTo: fieldsView.trailingAnchor, constant: -10),
        cvcField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    postalCodeField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        postalCodeField.topAnchor.constraint(equalTo: cvcField.bottomAnchor, constant: 10),
        postalCodeField.leadingAnchor.constraint(equalTo: fieldsView.leadingAnchor, constant: 10),
        postalCodeField.bottomAnchor.constraint(equalTo: fieldsView.bottomAnchor, constant: -0),
        postalCodeField.heightAnchor.constraint(equalToConstant: 44),
        postalCodeField.widthAnchor.constraint(equalTo: expirationField.widthAnchor),
      ]
    )
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
