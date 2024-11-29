// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

public class MultiLineCardForm: UIControl, CardForm {
  // MARK: - Public
  public var delegate: CardFormDelegate? = .none

  override public var isEnabled: Bool {
    get {
      super.isEnabled
    }
    set {
      super.isEnabled = newValue
      for field in allFields {
        field.isEnabled = newValue
      }
    }
  }

  public func clear() {
    for field in allFields {
      field.text = .init()
    }

    viewModel.cardNumber = .none
    viewModel.rawExpiration = .none
    viewModel.cvc = .none
    viewModel.postalCode = .none

    onChange()

    _ = numberField.becomeFirstResponder()
  }

  // MARK: - UIResponder
  override public func becomeFirstResponder() -> Bool {
    let firstResponder = currentFirstResponderField ?? nextFirstResponderField
    return firstResponder.becomeFirstResponder()
  }

  override public func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    return currentFirstResponderField?.resignFirstResponder() ?? false
  }

  // MARK: - Trait Collections
  override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
      updateAppearance()
    }
  }

  // MARK: - CardForm
  public var isValid: Bool {
    viewModel.isValid
  }

  // MARK: - Private
  private let cardImageManager = MultiLineCardImageManager()
  private let fieldEditingTransitionManager = SPCardFormFieldEditingTransitionManager()
  private var allFields: [LineTextField] {
    [numberField, expirationField, cvcField, postalCodeField]
  }

  let styleOptions: StyleOptions

  // MARK: - Subviews
  private lazy var numberField: LineTextField = {
    let textField = buildTextField()
    textField.textContentType = .creditCardNumber
    textField.autoFormattingBehavior = .cardNumbers
    textField.tag = SPCardFieldType.number.rawValue
    textField.floatingPlaceholder = "Card number"
    textField.rightViewMode = .always

    return textField
  }()

  private lazy var expirationField: LineTextField = {
    let textField = buildTextField()
    textField.autoFormattingBehavior = .expiration
    textField.tag = SPCardFieldType.expiration.rawValue
    textField.floatingPlaceholder = "Expiry date"

    return textField
  }()

  private lazy var cvcField: LineTextField = {
    let textField = buildTextField()
    textField.tag = SPCardFieldType.CVC.rawValue
    textField.floatingPlaceholder = "CVC"
    textField.rightViewMode = .always

    return textField
  }()

  private lazy var postalCodeField: LineTextField = {
    let textField = buildTextField()
    textField.textContentType = .postalCode
    textField.keyboardType = .default
    textField.tag = SPCardFieldType.postalCode.rawValue
    textField.floatingPlaceholder = "Postal code"

    return textField
  }()

  private lazy var expirationAndCvcStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [expirationField, cvcField])
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.distribution = .fillEqually
    stackView.alignment = .top

    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  private lazy var postalCodeTitleLabel: UILabel = {
    let label = buildTitleLabel()
    label.text = "BILLING ADDRESS"

    return label
  }()

  private lazy var cardInformationTitleLabel: UILabel = {
    let label = buildTitleLabel()
    label.text = "CARD INFORMATION"

    return label
  }()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(
      arrangedSubviews: [
        cardInformationTitleLabel,
        numberField,
        expirationAndCvcStackView,
        postalCodeTitleLabel,
        postalCodeField,
      ]
    )
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.setCustomSpacing(12, after: numberField)
    stackView.setCustomSpacing(28, after: expirationAndCvcStackView)

    stackView.translatesAutoresizingMaskIntoConstraints = false

    return stackView
  }()

  // MARK: - Internal
  let viewModel: CardFormViewModel = .init()

  // MARK: - Initializers
  override public init(frame: CGRect) {
    styleOptions = .default
    super.init(frame: frame)
    setUpSubViews()
  }

  required init?(coder: NSCoder) {
    styleOptions = .default
    super.init(coder: coder)
    setUpSubViews()
  }

  public init(
    config: ClientConfiguration,
    fieldOptions: FieldOptions = .default,
    styleOptions: StyleOptions = .default
  ) {
    self.styleOptions = styleOptions
    viewModel.apiClient = .init(config: config)
    viewModel.cvcDisplayConfig = fieldOptions.cvv.display
    viewModel.postalCodeDisplayConfig = fieldOptions.postalCode.display
    super.init(frame: .zero)
    setUpSubViews()

    layoutIfNeeded()
  }
}

// MARK: - Set Up Views
private extension MultiLineCardForm {
  private func setUpSubViews() {
    addSubview(stackView)

    configureViews()
    constraintViews()
  }

  func configureViews() {
    cvcField.isHidden = !viewModel.cvcDisplayed
    for view in [postalCodeTitleLabel, postalCodeField] {
      view.isHidden = !viewModel.postalCodeDisplayed
    }

    updateImages()
  }

  // swiftlint:disable function_body_length
  func constraintViews() {
    let constraints: [NSLayoutConstraint] = [
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
    ]
    for constraint in constraints {
      constraint.priority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)
    }
    NSLayoutConstraint.activate(constraints)
  }

  // swiftlint:enable function_body_length

  func buildTextField() -> LineTextField {
    let textField = LineTextField(frame: .zero)
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.keyboardType = .asciiCapableNumberPad
    textField.formDelegate = self
    textField.errorMessage = .none
    textField.autocorrectionType = .no
    textField.clearButtonMode = .never

    textField.backgroundColor = .clear
    textField.defaultColor = .darkText
    textField.errorColor = .systemRed

    textField.appearance = buildTextFieldAppearanceConfig()

    return textField
  }

  func buildTitleLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.textAlignment = .left

    applyTitleLabelAppearanceConfig(on: label)

    return label
  }
}

// MARK: - CardFormDelegate Calls
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

// MARK: - Icon management
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
      brandImageSet: styleOptions.iconSet.iconSet(for: traitCollection) == .dark ? .dark : .light,
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
      brandImageSet: .light,
      isValid: isValid
    )
  }
}

// MARK: - SPFormTextFieldDelegate
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
    guard let fieldType = SPCardFieldType(rawValue: textField.tag),
          let textField = textField as? LineTextField else {
      return
    }

    let isMidEditingTransition =
      fieldEditingTransitionManager.getAndUpdateState(fromCall: .didEnd)

    onDidEndEditingField(fieldType: fieldType)

    if !isMidEditingTransition {
      updateImages()
      onDidEndEditing()
    }

    realTimeValidationForField(fieldType, isFocused: false)
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

//    if fieldType == .number {
//      // Changing the card number field can invalidate the CVC, e.g., going from 4
//      // digit Amex CVC to 3 digit Visa
//      realTimeValidationForField(.CVC, isFocused: false)
//    }

    realTimeValidationForField(fieldType, isFocused: true)

    let state = viewModel.validationState(for: fieldType)

    switch state {
    case .incomplete,
         .invalid:
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
         is pretty light, we want to block auto-advance here.
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

// MARK: - First responder manager
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

// MARK: - Invalid field management
extension MultiLineCardForm {
  var firstInvalidSubField: LineTextField? {
    allFields.first { field in
      guard let fieldType = SPCardFieldType(rawValue: field.tag) else { return false }
      return viewModel.isFieldRequired(fieldType) && !viewModel.isFieldValid(fieldType)
    }
  }
}

// MARK: - Realtime Validation
extension MultiLineCardForm {
  func realTimeValidationForField(_ fieldType: SPCardFieldType, isFocused: Bool) {
    if let error = viewModel.realTimeValidationForField(fieldType, isFocused: isFocused) {
      handleValidationError(error)
    } else {
      let field = allFields.first { $0.tag == fieldType.rawValue }
      field?.errorMessage = .none
    }
  }
}

// MARK: - On Submit Validation
extension MultiLineCardForm {
  func validateForm() -> Bool {
    onWillEndEditingForReturn()
    _ = resignFirstResponder()

    let errors = formValidation()

    // Reset all fields to valid
    resetAllFieldsToValid()

    // Handle errors
    for error in errors {
      handleValidationError(error)
    }

    becomeFirstResponder()

    return errors.isEmpty
  }

  private func formValidation() -> [FormValidationError] {
    allFields.compactMap { field in
      guard let fieldType = SPCardFieldType(rawValue: field.tag) else {
        return .none
      }
      return viewModel.formValidationForField(fieldType)
    }
  }

  private func handleValidationError(_ error: FormValidationError) {
    // Look up for the field that failed
    let failedField: LineTextField

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
    }

    handleFailedField(failedField, errorMessage: error.localizedDescription)
  }
}

// MARK: - API Error handling
extension MultiLineCardForm {
  func handleAPIError(_ error: APIError) {
    let fieldErrors = error.fieldErrors

    if !fieldErrors.isEmpty {
      // Reset all fields to valid
      resetAllFieldsToValid()

      // Handle error
      for error in fieldErrors {
        handleFailedAPIError(error)
      }
    }
  }

  private func handleFailedAPIError(_ fieldError: APIError.FieldError) {
    let failedField: LineTextField?

    switch fieldError.fieldName {
    case "accountNumber":
      failedField = numberField
    case "cvv":
      failedField = cvcField
    case "expDate":
      failedField = expirationField
    case "billingAddress.postalCode":
      failedField = postalCodeField
    default:
      failedField = .none
    }

    guard let failedField, let errorMessages = fieldError.message else {
      return
    }

    handleFailedField(failedField, errorMessage: errorMessages)
  }

  private func handleFailedField(_ failedField: LineTextField, errorMessage: String) {
    guard let failedFieldType = SPCardFieldType(rawValue: failedField.tag) else {
      return
    }

    failedField.errorMessage = errorMessage

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

  private func resetAllFieldsToValid() {
    for field in allFields {
      field.errorMessage = .none
    }
  }
}

// MARK: - Appearance
extension MultiLineCardForm {
  func updateAppearance() {
    for field in allFields {
      field.appearance = buildTextFieldAppearanceConfig()
    }

    for label in [postalCodeTitleLabel, cardInformationTitleLabel] {
      applyTitleLabelAppearanceConfig(on: label)
    }

    updateImages()
  }

  func applyTitleLabelAppearanceConfig(on label: UILabel) {
    let textColor = styleOptions.colors.palette(
      for: traitCollection
    ).headerColor
    let font = styleOptions.typography.scaledFont

    label.textColor = textColor
    label.font = font
  }

  func buildTextFieldAppearanceConfig() -> LineTextField.AppearanceConfiguration {
    let currentPalette = styleOptions.colors.palette(for: traitCollection)
    let theme = currentPalette.theme

    return .init(
      backgroundInactiveColor: currentPalette.fieldBackgroundInactiveColor,
      backgroundInvalidColor: currentPalette.fieldBackgroundInvalidColor,
      backgroundFocusValidColor: currentPalette.fieldBackgroundFocusValidColor,
      backgroundFocusInvalidColor: currentPalette.fieldBackgroundFocusInvalidColor,
      borderInactiveColor: currentPalette.fieldOutlineInactiveColor,
      borderInvalidColor: currentPalette.fieldOutlineInvalidColor,
      borderFocusValidColor: currentPalette.fieldOutlineFocusValidColor,
      borderFocusInvalidColor: currentPalette.fieldOutlineFocusInvalidColor,
      floatingPlaceholderInactiveColor: currentPalette.fieldLabelInactiveColor,
      floatingPlaceholderInvalidColor: currentPalette.fieldLabelInvalidColor,
      floatingPlaceholderFocusValidColor: currentPalette.fieldLabelFocusValidColor,
      floatingPlaceholderFocusInvalidColor: currentPalette.fieldLabelFocusInvalidColor,
      textInactiveColor: currentPalette.fieldTextInactiveColor,
      textInvalidColor: currentPalette.fieldTextFocusInvalidColor,
      textFocusValidColor: currentPalette.fieldTextFocusValidColor,
      textFocusInvalidColor: currentPalette.fieldTextFocusInvalidColor,
      tintValidColor: theme.primary,
      tintInvalidColor: theme.danger,
      imageInactiveColor: currentPalette.fieldIconInactiveColor,
      imageInvalidColor: currentPalette.fieldIconInvalidColor,
      imageFocusValidColor: currentPalette.fieldIconFocusValidColor,
      imageFocusInvalidColor: currentPalette.fieldIconFocusInvalidColor,
      errorColor: currentPalette.errorMessageColor,
      cornerRadius: styleOptions.shapes.cornerRadius,
      borderWidth: 2,
      textFont: styleOptions.typography.scaledFont,
      errorFont: styleOptions.typography.scaledFont(
        for: styleOptions.typography.font.withSize(12)
      ),
      floatingPlaceholderFont: styleOptions.typography.scaledFont(
        for: styleOptions.typography.font.withSize(16)
      )
    )
  }
}
