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
    static let textOriginY: CGFloat = 12.5
    static let paddingX: CGFloat = 15.0
    static let paddingYElements: CGFloat = 3.0
    static let paddingYFloatLabel: CGFloat = 10.0
    static let animationDuration: TimeInterval = 0.2
    static let textInputFieldHeight: CGFloat = 70.0
  }

  // MARK: - UI Components
  let floatingPlaceholderLabel = UILabel()
  let errorLabel = UILabel()
  private let backgroundFrameLayer = CALayer()

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

    // Floating placeholder colors
    var floatingPlaceholderInactiveColor: UIColor = .systemGray
    var floatingPlaceholderInvalidColor: UIColor = .systemRed
    var floatingPlaceholderFocusValidColor: UIColor = .systemBlue
    var floatingPlaceholderFocusInvalidColor: UIColor = .systemRed

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
    var borderWidth: CGFloat = 2.0

    // Font
    var textFont: UIFont = .systemFont(ofSize: 18)
    var errorFont: UIFont = .systemFont(ofSize: 12)
    var floatingPlaceholderFont: UIFont = .systemFont(ofSize: 16)
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

  var errorMessage: String? {
    get { errorLabel.text }
    set {
      errorLabel.text = newValue
      updateAppearance()
    }
  }

  private var isFirsResponderTransition = false

  private var originX: CGFloat {
    var originX = Constants.paddingX

    if let leftView = leftView {
      originX += leftView.frame.maxX
    }

    return originX
  }

  private var floatingPlaceholderHeight: CGFloat {
    floatingPlaceholderLabel.textRect(
      forBounds: CGRect(
        x: 0,
        y: 0,
        width: CGFloat.greatestFiniteMagnitude,
        height: CGFloat.greatestFiniteMagnitude
      ),
      limitedToNumberOfLines: 1
    ).height
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

  // MARK: - Layout
  override public func layoutSubviews() {
    super.layoutSubviews()
    if !isFirsResponderTransition {
      updatePlaceholder(animated: false)
    }
    updateErrorLabel()
    updateBackgroundLayer()
  }

  // MARK: - UIResponder
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

  private func handleResponderTransition() {
    isFirsResponderTransition = true
    updatePlaceholder(animated: true)
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

  override public var rightView: UIView? {
    get { rightImageView }
    set { super.rightView = rightImageView }
  }

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
      width: frame.width,
      height: frame.height - errorMessageHeight - Constants.paddingYElements
    )
  }

  private func updatePlaceholder(animated: Bool) {
    guard placeholder?.isEmpty ?? true else { return }
    let shouldFloat = isEditing || !(text?.isEmpty ?? true)
    toggleFloatingPlaceholder(toFloat: shouldFloat, animated: animated)
  }

  private func toggleFloatingPlaceholder(toFloat: Bool, animated: Bool) {
    let newFrame = CGRect(
      x: originX,
      y: toFloat
        ? Constants.paddingYFloatLabel
        : (
          frame.height - floatingPlaceholderHeight - errorMessageHeight - Constants.paddingYElements
        ) / 2,
      width: floatingPlaceholderWidth,
      height: floatingPlaceholderHeight
    )

    let updateFrame = { self.floatingPlaceholderLabel.frame = newFrame }

    if animated {
      UIView.animate(
        withDuration: Constants.animationDuration,
        delay: 0,
        options: [.beginFromCurrentState, .curveEaseIn],
        animations: updateFrame
      ) { _ in
        self.layoutIfNeeded()
      }
    } else {
      updateFrame()
    }
  }

  // MARK: - Overridden UITextField methods
  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    insetRectForBounds(rect: super.textRect(forBounds: bounds))
  }

  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    insetRectForBounds(rect: super.editingRect(forBounds: bounds))
  }

  override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.leftViewRect(forBounds: bounds)
    rect.origin.y
      = (bounds.height - rect.size.height - errorMessageHeight - Constants.paddingYElements) / 2
    rect.origin.x += Constants.paddingX
    return rect
  }

  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.y
      = (bounds.height - rect.size.height - errorMessageHeight - Constants.paddingYElements) / 2
    rect.origin.x -= Constants.paddingX
    return rect
  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.clearButtonRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
    return rect
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

  override public var intrinsicContentSize: CGSize {
    return CGSize(
      width: UIView.noIntrinsicMetric,
      height: Constants.textInputFieldHeight + errorMessageHeight + Constants.paddingYElements
    )
  }
}

// MARK: - Appearance
extension LineTextField {
  func updateAppearance() {
    backgroundFrameLayer.cornerRadius = appearance.cornerRadius
    backgroundFrameLayer.borderWidth = appearance.borderWidth
    font = appearance.textFont
    floatingPlaceholderLabel.font = appearance.floatingPlaceholderFont
    errorLabel.font = appearance.errorFont

    let isFieldValid = errorMessage?.isEmpty ?? true

    errorLabel.textColor = appearance.errorColor
    switch (isFirstResponder, isFieldValid) {
    case (true, true): // focus and valid
      backgroundFrameLayer.borderColor = appearance.borderFocusValidColor.cgColor
      backgroundFrameLayer.backgroundColor = appearance.backgroundFocusValidColor.cgColor
      floatingPlaceholderLabel.textColor = appearance.floatingPlaceholderFocusValidColor

      rightImageView.tintColor = appearance.imageFocusValidColor
      tintColor = appearance.tintValidColor
      textColor = appearance.textFocusValidColor
    case (true, false): // focus and invalid
      backgroundFrameLayer.borderColor = appearance.borderFocusInvalidColor.cgColor
      backgroundFrameLayer.backgroundColor = appearance.backgroundFocusInvalidColor.cgColor
      floatingPlaceholderLabel.textColor = appearance.floatingPlaceholderFocusInvalidColor

      rightImageView.tintColor = appearance.imageFocusInvalidColor
      tintColor = appearance.tintInvalidColor
      textColor = appearance.textFocusInvalidColor
    case (false, true): // not focus and valid
      backgroundFrameLayer.borderColor = appearance.borderInactiveColor.cgColor
      backgroundFrameLayer.backgroundColor = appearance.backgroundInactiveColor.cgColor
      floatingPlaceholderLabel.textColor = appearance.floatingPlaceholderInactiveColor

      rightImageView.tintColor = appearance.imageInactiveColor
      tintColor = appearance.tintValidColor
      textColor = appearance.textInactiveColor
    case (false, false): // not focus and invalid
      backgroundFrameLayer.borderColor = appearance.borderInvalidColor.cgColor
      backgroundFrameLayer.backgroundColor = appearance.backgroundInvalidColor.cgColor
      floatingPlaceholderLabel.textColor = appearance.floatingPlaceholderInvalidColor

      rightImageView.tintColor = appearance.imageInvalidColor
      tintColor = appearance.tintInvalidColor
      textColor = appearance.textInvalidColor
    }

    invalidateIntrinsicContentSize()
    setNeedsLayout()
    layoutIfNeeded()
  }
}
