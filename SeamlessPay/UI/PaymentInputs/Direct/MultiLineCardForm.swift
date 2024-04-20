// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public class MultiLineCardForm: CardForm {
  // MARK: Private

  // MARK: Subviews
  private var numberField: SPFormTextField {
    class_getInstanceVariable(
      type(of: self),
      "_numberField"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? SPFormTextField
    }!
  }

  private var expirationField: SPFormTextField {
    class_getInstanceVariable(
      type(of: self),
      "_expirationField"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? SPFormTextField
    }!
  }

  private var cvcField: SPFormTextField {
    class_getInstanceVariable(
      type(of: self),
      "_cvcField"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? SPFormTextField
    }!
  }

  private var postalCodeField: SPFormTextField {
    class_getInstanceVariable(
      type(of: self),
      "_postalCodeField"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? SPFormTextField
    }!
  }

  private var fieldsView: UIView {
    class_getInstanceVariable(
      type(of: self),
      "_fieldsView"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? UIView
    }!
  }

  private var brandImageView: UIImageView {
    class_getInstanceVariable(
      type(of: self),
      "_brandImageView"
    )
    .flatMap {
      object_getIvar(self, $0)
    }
    .flatMap {
      $0 as? UIImageView
    }!
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

private extension MultiLineCardForm {}
