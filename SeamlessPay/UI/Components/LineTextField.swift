// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

public class LineTextField: SPFormTextField {
  // MARK: - Constants
  private enum Constants {
    static let textOriginY: CGFloat = 8
    static let paddingX: CGFloat = 15.0
    static let paddingYElements: CGFloat = 2.0
    static let paddingYFloatLabel: CGFloat = 10.0
    static let animationDuration: TimeInterval = 0.2
    static let textInputFieldHeight: CGFloat = 62.0
  }

  // MARK: - UI Components
  let floatingPlaceholderLabel = UILabel()
  let errorLabel = UILabel()
  private let backgroundFrameLayer = CAShapeLayer()

  // MARK: - Appearance Configuration
  public struct AppearanceConfiguration {
    // Background colors
    var backgroundInactiveColor: UIColor = .systemGray.withAlphaComponent(0.3)
    var backgroundInvalidColor: UIColor = .systemRed.withAlphaComponent(0.3)
    var backgroundFocusValidColor: UIColor = .clear
    var backgroundFocusInvalidColor: UIColor = .systemRed.withAlphaComponent(0.3)

    // Border colors
    var borderInactiveColor: UIColor = .clear
    var borderInvalidColor: UIColor = .clear
    var borderFocusValidColor: UIColor = .systemBlue
    var borderFocusInvalidColor: UIColor = .systemRed

    // Placeholder colors
    var placeholderInactiveColor: UIColor = .systemGray
    var placeholderInvalidColor: UIColor = .systemRed
    var placeholderFocusValidColor: UIColor = .systemBlue
    var placeholderFocusInvalidColor: UIColor = .systemRed

    // Text colors
    var textInactiveColor: UIColor = .darkText
    var textInvalidColor: UIColor = .systemRed
    var textFocusValidColor: UIColor = .darkText
    var textFocusInvalidColor: UIColor = .systemRed

    // Tint colors
    var tintValidColor: UIColor = .systemBlue
    var tintInvalidColor: UIColor = .systemRed

    // Image colors
    var imageInactiveColor: UIColor = .systemGray
    var imageInvalidColor: UIColor = .systemRed
    var imageFocusValidColor: UIColor = .systemBlue
    var imageFocusInvalidColor: UIColor = .systemRed

    // Error color
    var errorColor: UIColor = .systemRed

    // Sizes
    var cornerRadius: CGFloat = 5.0
    var borderWidth: CGFloat = 1.0

    // Font
    var textFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    var errorFont: UIFont = .systemFont(ofSize: 11, weight: .medium)
    var placeholderFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    var floatingPlaceholderFont: UIFont = .systemFont(ofSize: 11, weight: .medium)
  }

  public var appearance: AppearanceConfiguration = .init() {
    didSet {
      updateAppearance()
    }
  }

  // MARK: - Properties
  var floatingPlaceholder: String? {
    get { floatingPlaceholderLabel.text }
    set { floatingPlaceholderLabel.text = newValue }
  }

  private var placeholderShouldFloat: Bool {
    isEditing || !(text?.isEmpty ?? true)
  }

  var errorMessage: String? {
    get { errorLabel.text }
    set {
      // Changed error message and update appearance only if the error message is different
      if errorLabel.text != newValue {
        errorLabel.text = newValue
        updateAppearance()
      }
    }
  }

  private var isFirsResponderTransition = false

  private var originX: CGFloat {
    var originX = Constants.paddingX

    if let leftView {
      originX += leftView.frame.maxX
    }

    return originX
  }

  private var errorMessageHeight: CGFloat {
    errorLabel.textRect(
      forBounds: CGRect(
        x: 0,
        y: 0,
        width: errorLabel.frame.width,
        height: CGFloat.greatestFiniteMagnitude
      ),
      limitedToNumberOfLines: 0
    )
    .height
  }

  private var floatingPlaceholderWidth: CGFloat {
    var width = bounds.width
    if let leftViewWidth = leftView?.bounds.width {
      width -= leftViewWidth
    }
    if let rightViewWidth = rightView?.bounds.width {
      width -= rightViewWidth
    }

    width -= (originX * 2)

    return width
  }

  // MARK: - Overrides
  private var _placeholder: String?
  override public var placeholder: String? {
    get {
      return super.placeholder
    }
    set {
      _placeholder = newValue
      updateStaticPlaceholder()
    }
  }

  override public var rightView: UIView? {
    get { rightImageView }
    set { super.rightView = rightImageView }
  }

  override public var borderStyle: UITextField.BorderStyle {
    get { .none }
    set { super.borderStyle = .none }
  }

  override public var textAlignment: NSTextAlignment {
    get { .left }
    set { super.textAlignment = .left }
  }

  override public var clearButtonMode: UITextField.ViewMode {
    get { .never }
    set { super.clearButtonMode = .never }
  }

  // MARK: Layout
  override public func layoutSubviews() {
    super.layoutSubviews()
    updatePlaceholders(animated: isFirsResponderTransition)
    updateErrorLabel()
    updateBackgroundLayer()
  }

  // MARK: UIResponder
  override public func becomeFirstResponder() -> Bool {
    let result = super.becomeFirstResponder()
    handleResponderTransition()
    return result
  }

  override public func resignFirstResponder() -> Bool {
    let result = super.resignFirstResponder()
    handleResponderTransition()
    return result
  }

  // MARK: Overridden UITextField methods
  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    insetRectForBounds(rect: super.textRect(forBounds: bounds))
  }

  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    insetRectForBounds(rect: super.editingRect(forBounds: bounds))
  }

  override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    let textRect = insetRectForBounds(rect: super.textRect(forBounds: bounds))

    return textRect.offsetBy(dx: 3, dy: 0)
  }

  private func insetRectForBounds(rect: CGRect) -> CGRect {
    let rect = CGRect(
      x: originX,
      y: Constants.textOriginY,
      width: rect.width - originX - Constants.paddingX,
      height: rect.height - errorMessageHeight
    )

    return rect
  }

  override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.leftViewRect(forBounds: bounds)
    rect.origin.y = (
      bounds.height - rect.size.height - errorMessageHeight - Constants.paddingYElements
    ) / 2
    rect.origin.x += Constants.paddingX
    return rect
  }

  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.y = (
      bounds.height - rect.size.height - errorMessageHeight - Constants.paddingYElements
    ) / 2
    rect.origin.x -= Constants.paddingX
    return rect
  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.clearButtonRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
    return rect
  }

  override public var intrinsicContentSize: CGSize {
    return CGSize(
      width: UIView.noIntrinsicMetric,
      height: Constants.textInputFieldHeight + errorMessageHeight + Constants.paddingYElements
    )
  }

  override public func caretRect(for position: UITextPosition) -> CGRect {
    var rect = super.caretRect(for: position)
    rect.origin.y += Constants.paddingYElements
    rect.size.height -= Constants.paddingYElements * 2
    return rect
  }

  // MARK: - Initialization
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  private func commonInit() {
    setupTextField()
    setupBackgroundLayer()
    setupFloatingPlaceholder()
    setupErrorLabel()
    updateAppearance()
  }

  // MARK: - Setup Methods
  private func setupTextField() {
    textAlignment = .left
    borderStyle = .none
    rightView = rightImageView
  }

  private func setupBackgroundLayer() {
    backgroundFrameLayer.contentsScale = UIScreen.main.scale
    backgroundFrameLayer.lineJoin = .round
    backgroundFrameLayer.lineCap = .round
    layer.insertSublayer(backgroundFrameLayer, at: 0)
  }

  private func setupFloatingPlaceholder() {
    floatingPlaceholderLabel.numberOfLines = 1
    addSubview(floatingPlaceholderLabel)
  }

  private func setupErrorLabel() {
    errorLabel.numberOfLines = 0
    addSubview(errorLabel)
  }

  private func handleResponderTransition() {
    isFirsResponderTransition = true
    updateAppearance()
    isFirsResponderTransition = false
  }

  // MARK: - Custom UI
  lazy var rightImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    imageView.backgroundColor = .clear
    imageView.tintColor = placeholderColor
    imageView.isUserInteractionEnabled = false
    return imageView
  }()

  // MARK: - Private Interface
  private func updateErrorLabel() {
    errorLabel.frame = CGRect(
      x: 0,
      y: frame.height - errorMessageHeight,
      width: bounds.width,
      height: errorMessageHeight
    )
  }

  private func updateBackgroundLayer() {
    backgroundFrameLayer.frame = CGRect(
      x: 0,
      y: 0,
      width: bounds.width,
      height: bounds.height - errorMessageHeight - Constants.paddingYElements
    )

    let lineWidth = appearance.borderWidth
    let rect = backgroundFrameLayer.bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
    
    backgroundFrameLayer.path = UIBezierPath(
      roundedRect: rect,
      cornerRadius: appearance.cornerRadius
    ).cgPath
    backgroundFrameLayer.lineWidth = lineWidth
  }

  private func updatePlaceholders(animated: Bool) {
    updateFloatingPlaceholder(animated: animated)
    updateStaticPlaceholder()
  }

  private func updateFloatingPlaceholder(animated: Bool) {
    // Update font
    if placeholderShouldFloat {
      floatingPlaceholderLabel.font = appearance.floatingPlaceholderFont
    } else {
      floatingPlaceholderLabel.font = appearance.placeholderFont
    }

    // Update frame
    let originY: CGFloat

    let height = floatingPlaceholderLabel.font.lineHeight

    if placeholderShouldFloat {
      originY = Constants.paddingYFloatLabel
    } else {
      originY = (frame.height - height - errorMessageHeight - Constants.paddingYElements) / 2
    }

    let newFrame = CGRect(
      x: originX,
      y: originY,
      width: floatingPlaceholderWidth,
      height: height
    )
    
    let animationDuration = animated ? Constants.animationDuration : 0

    UIView.animate(
      withDuration: animationDuration,
      delay: 0,
      options: [.beginFromCurrentState, .curveEaseIn],
      animations: {
        self.floatingPlaceholderLabel.frame = newFrame
      },
      completion: { _ in
        self.layoutIfNeeded()
      }
    )
  }

  private func updateStaticPlaceholder() {
    let showPlaceholder = isEditing && (text?.isEmpty ?? true)
    super.placeholder = showPlaceholder ? _placeholder : .none
  }
}

// MARK: - Appearance
extension LineTextField {
  func updateAppearance() {
    // Update background layer
    updateBackgroundLayer()

    font = appearance.textFont
    errorLabel.font = appearance.errorFont

    let isFieldValid = errorMessage?.isEmpty ?? true

    errorLabel.textColor = appearance.errorColor
    placeholderColor = appearance.placeholderInactiveColor

    switch (isFirstResponder, isFieldValid) {
    case (true, true): // focus and valid
      backgroundFrameLayer.strokeColor = appearance.borderFocusValidColor.cgColor
      backgroundFrameLayer.fillColor = appearance.backgroundFocusValidColor.cgColor

      floatingPlaceholderLabel.textColor = appearance.placeholderFocusValidColor

      rightImageView.tintColor = appearance.imageFocusValidColor
      tintColor = appearance.tintValidColor
      textColor = appearance.textFocusValidColor
    case (true, false): // focus and invalid
      backgroundFrameLayer.strokeColor = appearance.borderFocusInvalidColor.cgColor
      backgroundFrameLayer.fillColor = appearance.backgroundFocusInvalidColor.cgColor

      floatingPlaceholderLabel.textColor = appearance.placeholderFocusInvalidColor

      rightImageView.tintColor = appearance.imageFocusInvalidColor
      tintColor = appearance.tintInvalidColor
      textColor = appearance.textFocusInvalidColor
    case (false, true): // not focus and valid
      backgroundFrameLayer.strokeColor = appearance.borderInactiveColor.cgColor
      backgroundFrameLayer.fillColor = appearance.backgroundInactiveColor.cgColor

      floatingPlaceholderLabel.textColor = appearance.placeholderInactiveColor

      rightImageView.tintColor = appearance.imageInactiveColor
      tintColor = appearance.tintValidColor
      textColor = appearance.textInactiveColor
    case (false, false): // not focus and invalid
      backgroundFrameLayer.strokeColor = appearance.borderInvalidColor.cgColor
      backgroundFrameLayer.fillColor = appearance.backgroundInvalidColor.cgColor

      floatingPlaceholderLabel.textColor = appearance.placeholderInvalidColor

      rightImageView.tintColor = appearance.imageInvalidColor
      tintColor = appearance.tintInvalidColor
      textColor = appearance.textInvalidColor
    }

    invalidateIntrinsicContentSize()
    setNeedsLayout()
    layoutIfNeeded()
  }
}
