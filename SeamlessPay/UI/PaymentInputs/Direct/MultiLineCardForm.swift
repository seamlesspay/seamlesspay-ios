// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public final class MultiLineCardForm: UIControl {
  // MARK: Public variables
  public var textColor: UIColor {
    if #available(iOS 13.0, *) {
      return .label
    } else {
      return .black
    }
  }

  public var textErrorColor: UIColor {
    if #available(iOS 13.0, *) {
      return .systemRed
    } else {
      return .red
    }
  }

  public let placeholderColor = UIColor.systemGray2
//  public var numberPlaceholder: String = .init()
//  public var expirationPlaceholder: String = .init()
//  public var cvcPlaceholder: String = .init()
//  public var postalCodePlaceholder: String = .init()
  public var font = UIFont.systemFont(ofSize: 18)

  // MARK: Private
  private let viewModel = SingleLineCardFormViewModel()

  // MARK: Subviews
  private let brandImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = SPImageLibrary.applePayCardImage()
    // Configure imageView
    return imageView
  }()

  private let numberField: SPFormTextField = {
    let textField = SPFormTextField()
    // Configure numberField
    return textField
  }()

  private let expirationField: SPFormTextField = {
    let textField = SPFormTextField()
    // Configure expirationField
    return textField
  }()

  private let cvcField: SPFormTextField = {
    let textField = SPFormTextField()
    // Configure cvcField
    return textField
  }()

  private let postalCodeField: SPFormTextField = {
    let textField = SPFormTextField()
    // Configure postalCodeField
    return textField
  }()

  // MARK: Init
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }

  public convenience init(
    authorization: Authorization,
    fieldOptions: FieldOptions = .default
  ) {
    self.init()
    setAuthorization(authorization)
    setFieldOptions(fieldOptions)
  }

  // MARK: Public
  public func setAuthorization(_ authorization: Authorization) {}

  public func setFieldOptions(_ fieldOptions: FieldOptions) {}

  // MARK: Private
  private func setupViews() {
    // Set background color
    backgroundColor = .gray
    clipsToBounds = true // Set self to clip to bounds

    configureTextField(numberField)
    numberField.textContentType = UITextContentType.creditCardNumber
    numberField.autoFormattingBehavior = .cardNumbers
    numberField.tag = SPCardFieldType.number.rawValue
    numberField.placeholder = ".... .... .... ...."

    configureTextField(expirationField)
    expirationField.autoFormattingBehavior = SPFormTextFieldAutoFormattingBehavior.expiration
    expirationField.tag = SPCardFieldType.expiration.rawValue
    expirationField.placeholder = "MM/YY"

    configureTextField(cvcField)
    cvcField.tag = SPCardFieldType.CVC.rawValue

    configureTextField(postalCodeField)
    postalCodeField.textContentType = UITextContentType.postalCode
    postalCodeField.tag = SPCardFieldType.postalCode.rawValue

    addSubview(numberField)
    addSubview(expirationField)
    addSubview(cvcField)
    addSubview(postalCodeField)
    addSubview(brandImageView)

    numberField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      numberField.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      numberField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
      numberField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -44),
      numberField.heightAnchor.constraint(equalToConstant: 44),
    ])

    brandImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      brandImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      brandImageView.centerYAnchor.constraint(equalTo: numberField.centerYAnchor),
    ])

    expirationField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      expirationField.topAnchor.constraint(equalTo: numberField.bottomAnchor, constant: 10),
      expirationField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
      expirationField.trailingAnchor.constraint(equalTo: cvcField.leadingAnchor, constant: -10),
      expirationField.widthAnchor.constraint(equalTo: cvcField.widthAnchor, multiplier: 1.5),
      expirationField.heightAnchor.constraint(equalToConstant: 44),
    ])

    cvcField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      cvcField.topAnchor.constraint(equalTo: expirationField.topAnchor),
      cvcField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0),
      cvcField.heightAnchor.constraint(equalToConstant: 44),
    ])

    postalCodeField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      postalCodeField.topAnchor.constraint(equalTo: cvcField.bottomAnchor, constant: 10),
      postalCodeField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
      postalCodeField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0),
      postalCodeField.heightAnchor.constraint(equalToConstant: 44),
      postalCodeField.widthAnchor.constraint(equalTo: expirationField.widthAnchor),
    ])

    numberField.backgroundColor = .yellow
    expirationField.backgroundColor = .green
    cvcField.backgroundColor = .blue
    postalCodeField.backgroundColor = .orange
    brandImageView.backgroundColor = .gray
  }
}

private extension MultiLineCardForm {
  func configureTextField(_ textField: SPFormTextField) {
    textField.backgroundColor = .clear
    textField.keyboardType = .asciiCapableNumberPad
    textField.textAlignment = .left
    textField.font = font
    textField.defaultColor = textColor
    textField.errorColor = textErrorColor
    textField.placeholderColor = placeholderColor
    textField.formDelegate = self
    textField.validText = true
  }
}

extension MultiLineCardForm: SPFormTextFieldDelegate {}
