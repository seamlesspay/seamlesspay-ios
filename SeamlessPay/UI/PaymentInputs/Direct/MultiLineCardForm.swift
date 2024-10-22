// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public class MultiLineCardForm: UIControl, CardForm {
  // MARK: Public
  public var delegate: CardFormDelegate? = .none

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

  // MARK: UIResponder
  override public func becomeFirstResponder() -> Bool {
    let firstResponder = currentFirstResponderField ?? nextFirstResponderField
    return firstResponder.becomeFirstResponder()
  }

  override public func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    return currentFirstResponderField?.resignFirstResponder() ?? false
  }

  // MARK: CardForm
  public var isValid: Bool {
    viewModel.isValid
  }

  // MARK: Private
  private let cardImageManager = MultiLineCardImageManager()
  private var allFields: [LineTextField] {
    [numberField, expirationField, cvcField, postalCodeField]
  }

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
    textField.floatingPlaceholder = "Card number"

    return textField
  }()

  private lazy var expirationField: LineTextField = {
    let textField = buildTextField()
    textField.autoFormattingBehavior = .expiration
    textField.tag = SPCardFieldType.expiration.rawValue
    textField.floatingPlaceholder = "Expiration date"

    return textField
  }()

  private lazy var cvcField: LineTextField = {
    let textField = buildTextField()
    textField.tag = SPCardFieldType.CVC.rawValue
    textField.floatingPlaceholder = "CVC"

    return textField
  }()

  private lazy var postalCodeField: LineTextField = {
    let textField = buildTextField()
    textField.textContentType = .postalCode
    textField.tag = SPCardFieldType.postalCode.rawValue
    textField.floatingPlaceholder = "Postal code"

    return textField
  }()

  private lazy var expirationAndCvcStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [expirationField, cvcField])
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.distribution = .fillEqually
    stackView.alignment = .fill

    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  private lazy var postalCodeTitleLabel: UILabel = {
    let label = buildTitleLabel()
    label.text = "BILLING ADDRESS"

    return label
  }()

  private lazy var postalCodeStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [postalCodeTitleLabel, postalCodeField])
    stackView.axis = .vertical
    stackView.spacing = 6
    stackView.distribution = .fill
    stackView.alignment = .fill

    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  private lazy var cardInformationTitleLabel: UILabel = {
    let label = buildTitleLabel()
    label.text = "CARD INFORMATION"

    return label
  }()

  private lazy var cardInformationStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [cardInformationTitleLabel, numberField])
    stackView.axis = .vertical
    stackView.spacing = 6
    stackView.distribution = .fill
    stackView.alignment = .fill

    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      cardInformationStackView,
      expirationAndCvcStackView,
      postalCodeStackView,
    ])
    stackView.axis = .vertical
    stackView.spacing = 14
    stackView.distribution = .fill
    stackView.alignment = .fill

    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  // MARK: Internal
  let viewModel: CardFormViewModel

  // MARK: Private variables
  private let fieldEditingTransitionManager = SPCardFormFieldEditingTransitionManager()

  // MARK: Constants
  private let textFieldHeight: CGFloat = 84

  // MARK: Initializers
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

  // MARK: Internal interface
  func setCVCDisplayConfig(_ displayConfig: DisplayConfiguration) {
    viewModel.cvcDisplayConfig = displayConfig
    cvcField.isHidden = !viewModel.cvcDisplayed

    layoutIfNeeded()
  }

  func setPostalCodeDisplayConfig(_ displayConfig: DisplayConfiguration) {
    viewModel.postalCodeDisplayConfig = displayConfig
    postalCodeStackView.isHidden = !viewModel.postalCodeDisplayed

    layoutIfNeeded()
  }
}

// MARK: Set Up Views
private extension MultiLineCardForm {
  private func setUpSubViews() {
    addSubview(stackView)

    configureViews()
    constraintViews()
  }

  func configureViews() {
    // Set placeholders for the fields

    numberField.rightViewMode = .always

    cvcField.rightViewMode = .always

    updateImages()

    countryCode = Locale.autoupdatingCurrent.identifier
  }

  // swiftlint:disable function_body_length
  func constraintViews() {
    let constraints: [NSLayoutConstraint] = [
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
    ]
    constraints.forEach {
      $0.priority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)
    }
    NSLayoutConstraint.activate(constraints)

    NSLayoutConstraint.activate([
      numberField.heightAnchor.constraint(equalToConstant: textFieldHeight),
      expirationField.heightAnchor.constraint(equalToConstant: textFieldHeight),
      cvcField.heightAnchor.constraint(equalToConstant: textFieldHeight),
      postalCodeField.heightAnchor.constraint(equalToConstant: textFieldHeight),
    ])
  }

  // swiftlint:enable function_body_length

  func buildTextField() -> LineTextField {
    let textField = LineTextField(frame: .zero)
    textField.backgroundColor = .clear
    textField.translatesAutoresizingMaskIntoConstraints = false
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

  func buildTitleLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16)
    label.textColor = .systemGray2
    label.numberOfLines = 0
    label.textAlignment = .left

    return label
  }
}

// MARK: CardFormDelegate Calls
private extension MultiLineCardForm {
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

// MARK: Icon management
private extension MultiLineCardForm {
  func updateImages() {
    updateCardNumberImage(
      isValid: viewModel.validationState(for: .number) != .invalid
    )

    updateCVCImage(
      isValid: viewModel.validationState(for: .CVC) != .invalid
    )
  }

  func updateCardNumberImage(
    isValid: Bool
  ) {
    cardImageManager.updateImageView(
      numberField,
      for: .number,
      brand: viewModel.brand,
      isValid: isValid
    )
  }

  func updateCVCImage(
    isValid: Bool
  ) {
    cardImageManager.updateImageView(
      cvcField,
      for: .cvc,
      brand: viewModel.brand,
      isValid: isValid
    )
  }
}

// MARK: SPFormTextFieldDelegate
extension MultiLineCardForm: SPFormTextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    fieldEditingTransitionManager.getAndUpdateState(fromCall: .shouldBegin)
    return true
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    let isMidEditingTransition =
      fieldEditingTransitionManager.getAndUpdateState(fromCall: .didBegin)

    if !isMidEditingTransition {
      onDidBeginEditing()
    }

    if let fieldType = SPCardFieldType(rawValue: textField.tag) {
      onDidBeginEditing(fieldType: fieldType)
    }
  }

  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    let _ = fieldEditingTransitionManager.getAndUpdateState(fromCall: .shouldEnd)
    updateImages()

    return true
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    guard let fieldType = SPCardFieldType(rawValue: textField.tag) else {
      return
    }

    let isMidEditingTransition =
      fieldEditingTransitionManager.getAndUpdateState(fromCall: .didEnd)

    onDidEndEditingField(fieldType: fieldType)

    if !isMidEditingTransition {
      updateImages()
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
      _ = nextFirstResponderField.becomeFirstResponder()
    }

    return false
  }

  public func formTextFieldTextDidChange(_ textField: SPFormTextField) {
    guard let fieldType = SPCardFieldType(rawValue: textField.tag),
          let textField = textField as? LineTextField else {
      return
    }

    // Reset the error message set during on submit validation
    // when the user starts changing the input
    textField.errorMessage = .none

    if fieldType == .number {
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
      _ = nextFirstResponderField.becomeFirstResponder()
    @unknown default:
      break
    }

    updateImages()
    onChange()
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

    _ = previousField.becomeFirstResponder()

    if previousField.hasText {
      previousField.deleteBackward()
    }
  }
}

// MARK: First responder manager
private extension MultiLineCardForm {
  var currentFirstResponderField: LineTextField? {
    allFields.first { $0.isFirstResponder }
  }

  var nextFirstResponderField: LineTextField {
    if let currentFirstResponderField,
       let currentIndex = allFields.firstIndex(of: currentFirstResponderField),
       currentIndex + 1 < allFields.count {
      let potentialNextField = allFields[currentIndex + 1]

      if let fieldType = SPCardFieldType(rawValue: potentialNextField.tag),
         viewModel.isFieldDisplayed(fieldType) {
        return potentialNextField
      }
    }

    return firstInvalidSubField ?? lastSubField
  }

  var previousField: LineTextField? {
    if let currentFirstResponderField,
       let index = allFields.firstIndex(of: currentFirstResponderField),
       index > 0 {
      return allFields[index - 1]
    }
    return .none
  }

  var lastSubField: LineTextField {
    if viewModel.postalCodeDisplayed {
      return postalCodeField
    } else if viewModel.cvcDisplayed {
      return cvcField
    } else {
      return expirationField
    }
  }
}

// MARK: Invalid field management
extension MultiLineCardForm {
  var firstInvalidSubField: LineTextField? {
    allFields.first { field in
      guard let fieldType = SPCardFieldType(rawValue: field.tag) else { return false }
      return viewModel.isFieldRequired(fieldType) && !viewModel.isFieldValid(fieldType)
    }
  }
}

// MARK: On Submit Validation
extension MultiLineCardForm {
  func validateSubmission() -> Bool {
    if let error = onSubmitValidation() {
      handleOnSubmitValidationError(error)
      return false
    }
    return true
  }

  private func onSubmitValidation() -> CardFormError? {
    for field in allFields {
      guard let fieldType = SPCardFieldType(rawValue: field.tag),
            let error = viewModel.onSubmitValidationForField(fieldType) else {
        continue
      }

      return error
    }

    return .none
  }

  private func handleOnSubmitValidationError(_ error: CardFormError) {

    // Reset all fields to valid
    allFields.forEach { field in
      field.validText = true
      field.errorMessage = .none
    }

    // Look up for the field that failed
    let failedField: LineTextField?

    switch error {
    case .numberInvalid,
         .numberRequired:
      failedField = numberField
    case .expirationInvalid,
         .expirationInvalidDate,
         .expirationRequired:
      failedField = expirationField
    case .cvcInvalid,
         .cvcRequired:
      failedField = cvcField
    case .postalCodeInvalid,
         .postalCodeRequired:
      failedField = postalCodeField
    case .clientError:
      failedField = .none
    }

    guard let failedField, let failedFieldType = SPCardFieldType(rawValue: failedField.tag) else {
      return
    }

    failedField.validText = false
    failedField.errorMessage = error.localizedDescription

    // Update the images to show the error state after stricter validation
    switch failedFieldType {
    case .number:
      updateCardNumberImage(isValid: false)
    case .CVC:
      updateCVCImage(isValid: false)
    default:
      break
    }
  }
}
 
