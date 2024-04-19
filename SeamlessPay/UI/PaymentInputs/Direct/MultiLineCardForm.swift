// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public class MultiLineCardForm: UIControl {
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
  private let cardLogoImageViewManager = CardLogoImageViewManager()

  // MARK: Subviews
  private let cardLogoImageView: UIImageView = {
    let imageView = UIImageView()
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

  private let fieldsView = UIView()

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

  public func clear() {
    updateCardLogoImage(for: .number)
  }

  // MARK: Override
  override public func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    updateCardLogoImage(for: .number)
    return true
  }
}

// MARK: Set Up Views
private extension MultiLineCardForm {
  func setupViews() {
    addSubview(fieldsView)
    fieldsView.addSubview(numberField)
    fieldsView.addSubview(cardLogoImageView)
    fieldsView.addSubview(expirationField)
    fieldsView.addSubview(cvcField)
    fieldsView.addSubview(postalCodeField)

    configureView()
    constraintViews()

    // TODO: Remove
    backgroundColor = .gray
    numberField.backgroundColor = .yellow
    expirationField.backgroundColor = .green
    cvcField.backgroundColor = .blue
    postalCodeField.backgroundColor = .orange
  }

  func configureView() {
    fieldsView.clipsToBounds = true
    fieldsView.backgroundColor = .white

    configureTextField(numberField)
    numberField.textContentType = UITextContentType.creditCardNumber
    numberField.autoFormattingBehavior = .cardNumbers
    numberField.tag = SPCardFieldType.number.rawValue
    numberField.placeholder = ".... .... .... ...."

    cardLogoImageView.contentMode = .center
    cardLogoImageView.tintColor = placeholderColor
    cardLogoImageView.backgroundColor = .clear
    updateCardLogoImage(for: .number)

    configureTextField(expirationField)
    expirationField.autoFormattingBehavior = SPFormTextFieldAutoFormattingBehavior.expiration
    expirationField.tag = SPCardFieldType.expiration.rawValue
    expirationField.placeholder = "MM/YY"

    configureTextField(cvcField)
    cvcField.tag = SPCardFieldType.CVC.rawValue

    configureTextField(postalCodeField)
    postalCodeField.textContentType = UITextContentType.postalCode
    postalCodeField.tag = SPCardFieldType.postalCode.rawValue
  }

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
        numberField.leadingAnchor.constraint(equalTo: fieldsView.leadingAnchor, constant: 0),
        numberField.trailingAnchor.constraint(equalTo: fieldsView.trailingAnchor, constant: -44),
        numberField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    cardLogoImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        cardLogoImageView.trailingAnchor.constraint(
          equalTo: fieldsView.trailingAnchor,
          constant: -10
        ),
        cardLogoImageView.centerYAnchor.constraint(equalTo: numberField.centerYAnchor),
      ]
    )

    expirationField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        expirationField.topAnchor.constraint(equalTo: numberField.bottomAnchor, constant: 10),
        expirationField.leadingAnchor.constraint(equalTo: fieldsView.leadingAnchor, constant: 0),
        expirationField.trailingAnchor.constraint(equalTo: cvcField.leadingAnchor, constant: -10),
        expirationField.widthAnchor.constraint(equalTo: cvcField.widthAnchor, multiplier: 1.5),
        expirationField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    cvcField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        cvcField.topAnchor.constraint(equalTo: expirationField.topAnchor),
        cvcField.trailingAnchor.constraint(equalTo: fieldsView.trailingAnchor, constant: -0),
        cvcField.heightAnchor.constraint(equalToConstant: 44),
      ]
    )

    postalCodeField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        postalCodeField.topAnchor.constraint(equalTo: cvcField.bottomAnchor, constant: 10),
        postalCodeField.leadingAnchor.constraint(equalTo: fieldsView.leadingAnchor, constant: 0),
        postalCodeField.bottomAnchor.constraint(equalTo: fieldsView.bottomAnchor, constant: -0),
        postalCodeField.heightAnchor.constraint(equalToConstant: 44),
        postalCodeField.widthAnchor.constraint(equalTo: expirationField.widthAnchor),
      ]
    )
  }

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

private extension MultiLineCardForm {
  func updateCardLogoImage(for fieldType: SPCardFieldType?) {
    guard let fieldType else { return }

    cardLogoImageViewManager.update(
      cardLogoImageView,
      fieldType: fieldType,
      brand: viewModel.brand,
      validation: viewModel.validationState(for: fieldType)
    )
  }
}

// MARK: SPFormTextFieldDelegate
extension MultiLineCardForm: SPFormTextFieldDelegate {
  public func formTextFieldTextDidChange(_ textField: SPFormTextField) {
    let cardFiledType = SPCardFieldType(rawValue: textField.tag)
    if cardFiledType == .number {
      updateCardLogoImage(for: .number)
    }
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    updateCardLogoImage(for: .init(rawValue: textField.tag))
  }

  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    updateCardLogoImage(for: .number)
    return true
  }
}
