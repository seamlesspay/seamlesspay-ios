// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public class MultiLineCardForm: UIControl, CardForm, UIKeyInput {
  // MARK: Public
  public var delegate: CardFormDelegate? = .none
  public var brandImage: UIImage? {
    brandImageView.image
  }

  override public var isEnabled: Bool {
    get {
      super.isEnabled
    }
    set {
      super.isEnabled = newValue
      allFields.forEach { field in
        field.isEnabled = newValue
      }
    }
  }

  public var countryCode: String? {
    get {
      viewModel.postalCodeCountryCode
    }
    set {
      viewModel.postalCodeCountryCode = newValue

      if countryCode == "US" {
        postalCodeField.keyboardType = .phonePad
      } else {
        postalCodeField.keyboardType = .default
      }
    }
  }

  public func clear() {
    allFields.forEach { field in
      field.text = .init()
    }

    viewModel.cardNumber = .none
    viewModel.rawExpiration = .none
    viewModel.cvc = .none
    viewModel.postalCode = .none
    onChange()

    _ = numberField.becomeFirstResponder()
  }

  override public func becomeFirstResponder() -> Bool {
    let firstResponder = currentFirstResponderField ?? nextFirstResponderField
    return firstResponder.becomeFirstResponder()
  }

  override public func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    return currentFirstResponderField?.resignFirstResponder() ?? false
  }

  // MARK: UIKeyInput
  public var hasText: Bool {
    return numberField.hasText || expirationField.hasText || cvcField.hasText
  }

  public func insertText(_ text: String) {
    currentFirstResponderField?.insertText(text)
  }

  public func deleteBackward() {
    currentFirstResponderField?.deleteBackward()
  }

  // MARK: CardForm
  public var isValid: Bool {
    viewModel.isValid
  }

  // MARK: Private
  private let cardLogoManager = CardLogoImageViewManager()
  private var allFields = [SPFormTextField]()

  // MARK: Appearance
  private var placeholderColor: UIColor {
    return UIColor.systemGray2
  }

  // MARK: Subviews
  private lazy var numberField: LineTextField = {
    let textField = buildTextField()
    textField.textContentType = .creditCardNumber
    textField.autoFormattingBehavior = .cardNumbers
    textField.tag = SPCardFieldType.number.rawValue

    return textField
  }()

  private lazy var expirationField: LineTextField = {
    let textField = buildTextField()
    textField.autoFormattingBehavior = .expiration
    textField.tag = SPCardFieldType.expiration.rawValue

    return textField
  }()

  private lazy var cvcField: LineTextField = {
    let textField = buildTextField()
    textField.tag = SPCardFieldType.CVC.rawValue

    return textField
  }()

  private lazy var postalCodeField: LineTextField = {
    let textField = buildTextField()
    textField.textContentType = .postalCode
    textField.tag = SPCardFieldType.postalCode.rawValue

    return textField
  }()

  private lazy var fieldsView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    view.backgroundColor = .clear

    return view
  }()

  private lazy var boundedView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    view.backgroundColor = .white
    view.layer.borderColor = placeholderColor.cgColor
    view.layer.cornerRadius = 5.0
    view.layer.borderWidth = 1.0

    return view
  }()

  private lazy var brandImageView: UIImageView = {
    let imageView = UIImageView(image: nil)
    imageView.contentMode = .center
    imageView.backgroundColor = .clear
    imageView.tintColor = placeholderColor
    imageView.isUserInteractionEnabled = false

    return imageView
  }()

  // MARK: Internal
  let viewModel: CardFormViewModel

  // MARK: Private variables
  private var fieldsViewBottomConstraint: NSLayoutConstraint?
  private let fieldEditingTransitionManager = SPCardFormFieldEditingTransitionManager()

  // MARK: Interface
  override public init(frame: CGRect) {
    viewModel = .init()
    super.init(frame: frame)
    setUpSubViews()
  }

  required init?(coder: NSCoder) {
    viewModel = .init()
    super.init(coder: coder)
    setUpSubViews()
  }

  func setCVCDisplayConfig(_ displayConfig: CardFieldDisplay) {
    let isCVCHidden = displayConfig == .none
    let isCVCRequired = displayConfig == .required

    viewModel.cvcDisplayed = !isCVCHidden
    viewModel.cvcRequired = isCVCRequired

    cvcField.isHidden = isCVCHidden

    layoutIfNeeded()
  }

  func setPostalCodeDisplayConfig(_ displayConfig: CardFieldDisplay) {
    let isPostalCodeHidden = displayConfig == .none
    let isPostalCodeRequired = displayConfig == .required

    viewModel.postalCodeDisplayed = !isPostalCodeHidden
    viewModel.postalCodeRequired = isPostalCodeRequired
    updateFieldsViewBottomConstraint(isPostalCodeHidden: isPostalCodeHidden)
    postalCodeField.isHidden = isPostalCodeHidden

    layoutIfNeeded()
  }

  // MARK: Private

  private func setUpSubViews() {
    addSubview(boundedView)

    boundedView.addSubview(fieldsView)

    fieldsView.addSubview(numberField)
    fieldsView.addSubview(expirationField)
    fieldsView.addSubview(cvcField)
    fieldsView.addSubview(postalCodeField)

    allFields = [numberField, expirationField, cvcField, postalCodeField]

    configureViews()
    constraintViews()
  }
}

// MARK: Set Up Views
private extension MultiLineCardForm {
  func configureViews() {
    // Set placeholders for the fields
    numberField.floatingPlaceholder = "Card number"
    expirationField.floatingPlaceholder = "Expiry date"
    cvcField.floatingPlaceholder = "CVC"
    postalCodeField.floatingPlaceholder = "Postal code"

    numberField.rightView = brandImageView
    numberField.rightViewMode = .always

    updateImageForFieldType(.number)
    countryCode = Locale.autoupdatingCurrent.identifier
  }

  // swiftlint:disable function_body_length
  func constraintViews() {
    let offset1: CGFloat = 10
    let textFieldHeight: CGFloat = 60

    boundedView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        boundedView.centerYAnchor.constraint(equalTo: centerYAnchor),
        boundedView.centerXAnchor.constraint(equalTo: centerXAnchor),
        boundedView.widthAnchor.constraint(equalTo: widthAnchor),
        boundedView.heightAnchor.constraint(equalTo: heightAnchor),
      ]
    )

    fieldsView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        fieldsView.centerXAnchor.constraint(equalTo: boundedView.centerXAnchor),
        fieldsView.centerYAnchor.constraint(equalTo: boundedView.centerYAnchor),
        fieldsView.widthAnchor.constraint(equalTo: boundedView.widthAnchor, constant: -30),
      ]
    )

    fieldsViewBottomConstraint = fieldsView.bottomAnchor.constraint(
      equalTo: postalCodeField.bottomAnchor,
      constant: -0
    )

    updateFieldsViewBottomConstraint(isPostalCodeHidden: false)

    numberField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        numberField.topAnchor.constraint(equalTo: fieldsView.topAnchor, constant: 0),
        numberField.leadingAnchor.constraint(
          equalTo: fieldsView.leadingAnchor,
          constant: offset1
        ),
        numberField.trailingAnchor.constraint(
          equalTo: fieldsView.trailingAnchor,
          constant: -offset1
        ),
        numberField.heightAnchor.constraint(equalToConstant: textFieldHeight),
      ]
    )

    expirationField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        expirationField.topAnchor.constraint(
          equalTo: numberField.bottomAnchor,
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
        expirationField.heightAnchor.constraint(equalToConstant: textFieldHeight),
      ]
    )

    cvcField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        cvcField.centerYAnchor.constraint(equalTo: expirationField.centerYAnchor),
        cvcField.trailingAnchor.constraint(equalTo: fieldsView.trailingAnchor, constant: -offset1),
        cvcField.heightAnchor.constraint(equalToConstant: textFieldHeight),
      ]
    )

    postalCodeField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        postalCodeField.topAnchor.constraint(
          equalTo: cvcField.bottomAnchor,
          constant: offset1
        ),
        postalCodeField.leadingAnchor.constraint(
          equalTo: fieldsView.leadingAnchor,
          constant: offset1
        ),
        postalCodeField.heightAnchor.constraint(equalToConstant: textFieldHeight),
        postalCodeField.widthAnchor.constraint(equalTo: expirationField.widthAnchor),
      ]
    )
  }

  // swiftlint:enable function_body_length

  func updateFieldsViewBottomConstraint(isPostalCodeHidden: Bool) {
    fieldsViewBottomConstraint?.isActive = false

    let bottomAnchor = isPostalCodeHidden
      ? expirationField.bottomAnchor
      : postalCodeField.bottomAnchor

    fieldsViewBottomConstraint = fieldsView.bottomAnchor.constraint(
      equalTo: bottomAnchor,
      constant: -0
    )

    fieldsViewBottomConstraint?.isActive = true
  }

  func buildTextField() -> LineTextField {
    let textField = LineTextField(frame: .zero)
    textField.backgroundColor = .clear
    textField.keyboardType = .asciiCapableNumberPad
    textField.font = .systemFont(ofSize: 18)
    textField.defaultColor = .darkText
    textField.errorColor = .systemRed
    textField.placeholderColor = placeholderColor
    textField.formDelegate = self
    textField.validText = true
    textField.autocorrectionType = .no
    textField.clearButtonMode = .never

    return textField
  }

  func updateImageForFieldType(_ fieldType: SPCardFieldType) {
    cardLogoManager.update(
      brandImageView,
      fieldType: fieldType,
      brand: viewModel.brand,
      validation: viewModel.validationState(for: fieldType)
    )
  }

  func onChange() {
    let selector = NSSelectorFromString("cardFormDidChange:")
    if let delegate, delegate.responds(to: selector) {
      delegate.cardFormDidChange?(self)
    }
    sendActions(for: .valueChanged)
  }

  func onDidBeginEditing() {
    let selector = NSSelectorFromString("cardFormDidBeginEditing:")
    if let delegate, delegate.responds(to: selector) {
      delegate.cardFormDidBeginEditing?(self)
    }
  }

  func onDidBeginEditing(fieldType: SPCardFieldType) {
    let selector = NSSelectorFromString("cardForm:didBeginEditingField:")
    if let delegate, delegate.responds(to: selector) {
      delegate.cardForm?(self, didBeginEditing: fieldType)
    }
  }

  func onDidEndEditingField(fieldType: SPCardFieldType) {
    let selector = NSSelectorFromString("cardForm:didEndEditingField:")
    if let delegate, delegate.responds(to: selector) {
      delegate.cardForm?(self, didEndEditing: fieldType)
    }
  }

  func onDidEndEditing() {
    let selector = NSSelectorFromString("cardFormDidEndEditing:")
    if let delegate, delegate.responds(to: selector) {
      delegate.cardFormDidEndEditing?(self)
    }
  }

  func onWillEndEditingForReturn() {
    let selector = NSSelectorFromString("cardFormWillEndEditingForReturn:")
    if let delegate, delegate.responds(to: selector) {
      delegate.cardFormWillEndEditing?(forReturn: self)
    }
  }
}

// MARK: SPFormTextFieldDelegate
extension MultiLineCardForm: SPFormTextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    fieldEditingTransitionManager.getAndUpdateState(fromCall: .shouldBegin)
    return true
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    let isMidEditingTransition = fieldEditingTransitionManager
      .getAndUpdateState(fromCall: .didBegin)

    if !isMidEditingTransition {
      onDidBeginEditing()
    }

    if let fieldType = SPCardFieldType(rawValue: textField.tag) {
      onDidBeginEditing(fieldType: fieldType)
    }
  }

  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    let _ = fieldEditingTransitionManager.getAndUpdateState(fromCall: .shouldEnd)
    updateImageForFieldType(.number)

    return true
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    guard let fieldType = SPCardFieldType(rawValue: textField.tag) else {
      return
    }

    let isMidEditingTransition = fieldEditingTransitionManager.getAndUpdateState(fromCall: .didEnd)

    if fieldType == .number {
      let validationState = viewModel.validationState(for: .number)

      if validationState == .incomplete {
        (textField as? SPFormTextField)?.validText = false
      }
    }

    onDidEndEditingField(fieldType: fieldType)

    if !isMidEditingTransition {
      updateImageForFieldType(.number)
      onDidEndEditing()
    }
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == lastSubField && firstInvalidSubField == .none {
      // User pressed return in the last field, and all fields are valid
      onWillEndEditingForReturn()
      _ = resignFirstResponder()
    } else {
      // Otherwise, move to the next field
      nextFirstResponderField.becomeFirstResponder()
    }

    return false
  }

  public func formTextFieldTextDidChange(_ textField: SPFormTextField) {
    defer { onChange() }
    guard let fieldType = SPCardFieldType(rawValue: textField.tag) else {
      return
    }

    if fieldType == .number {
      updateImageForFieldType(.number)

      // Changing the card number field can invalidate the CVC, e.g., going from 4
      // digit Amex CVC to 3 digit Visa
      cvcField.validText = viewModel.validationState(for: .CVC) != .invalid
    }

    let state = viewModel.validationState(for: fieldType)
    textField.validText = true

    switch state {
    case .invalid:
      textField.validText = false
    case .incomplete:
      break
    case .valid:
      if fieldType == .CVC {
        /*
         Even though any CVC longer than the min required CVC length
         is valid, we don't want to forward on to the next field
         unless it is actually >= the max CVC length (otherwise when
         postal code is showing, you can't easily enter CVCs longer than
         the minimum.
         */
        let sanitizedCvc = SPCardValidator.sanitizedNumericString(for: textField.text ?? "")
        if sanitizedCvc.count < SPCardValidator.maxCVCLength(for: viewModel.brand) {
          break
        }
      } else if fieldType == .postalCode {
        /*
         Similar to the UX problems on CVC, since our Postal Code validation
         is pretty light, we want to block auto-advance here. In the US, this
         allows users to enter 9 digit zips if they want, and as many as they
         need in non-US countries (where >0 characters is "valid")
         */
        break
      }

      // This is a no-op if this is the last field & they're all valid
      nextFirstResponderField.becomeFirstResponder()
    @unknown default:
      break
    }
  }

  public func formTextField(
    _ formTextField: SPFormTextField,
    modifyIncomingTextChange input: NSAttributedString
  ) -> NSAttributedString {
    guard let fieldType = SPCardFieldType(rawValue: formTextField.tag) else {
      return NSAttributedString()
    }

    let attributes: [NSAttributedString.Key: Any] = formTextField.defaultTextAttributes
    let text: String?
    switch fieldType {
    case .number:
      viewModel.cardNumber = input.string
      text = viewModel.cardNumber
    case .expiration:
      viewModel.rawExpiration = input.string
      text = viewModel.rawExpiration
    case .CVC:
      viewModel.cvc = input.string
      text = viewModel.cvc
    case .postalCode:
      viewModel.postalCode = input.string
      text = viewModel.postalCode
    @unknown default:
      text = .none
    }

    return NSAttributedString(string: text ?? .init(), attributes: attributes)
  }

  public func formTextFieldDidBackspace(onEmpty formTextField: SPFormTextField) {
    guard let previousField else { return }

    previousField.becomeFirstResponder()

    if previousField.hasText {
      previousField.deleteBackward()
    }
  }
}

// MARK: First responder manager
private extension MultiLineCardForm {
  var currentFirstResponderField: SPFormTextField? {
    allFields.first { $0.isFirstResponder }
  }

  var firstInvalidSubField: SPFormTextField? {
    if !viewModel.isFieldValid(.number) {
      return numberField
    } else if !viewModel.isFieldValid(.expiration) {
      return expirationField
    } else if viewModel.cvcRequired, !viewModel.isFieldValid(.CVC) {
      return cvcField
    } else if viewModel.postalCodeRequired, !viewModel.isFieldValid(.postalCode) {
      return postalCodeField
    } else {
      return .none
    }
  }

  var nextFirstResponderField: SPFormTextField {
    if let currentFirstResponderField,
       let currentIndex = allFields.firstIndex(of: currentFirstResponderField),
       currentIndex + 1 < allFields.count {
      let potentialNextField = allFields[currentIndex + 1]

      if potentialNextField == postalCodeField && viewModel.postalCodeDisplayed {
        return potentialNextField
      } else if potentialNextField == cvcField && viewModel.cvcDisplayed {
        return potentialNextField

      } else {
        return potentialNextField
      }
    }

    return firstInvalidSubField ?? lastSubField
  }

  var previousField: SPFormTextField? {
    if let currentFirstResponderField,
       let index = allFields.firstIndex(of: currentFirstResponderField),
       index > 0 {
      return allFields[index - 1]
    }
    return .none
  }

  var lastSubField: SPFormTextField {
    if viewModel.postalCodeDisplayed {
      return postalCodeField
    } else if viewModel.cvcDisplayed {
      return cvcField
    } else {
      return expirationField
    }
  }
}
