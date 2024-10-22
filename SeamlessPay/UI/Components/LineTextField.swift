// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

public class LineTextField: SPFormTextField {
  // MARK: - UI Components
  private let floatingPlaceholderLabel = UILabel()
  private let errorLabel = UILabel()
  private let backgroundFrameLayer = CALayer()

  // MARK: - Constants
  private enum Constants {
    static let paddingX: CGFloat = 10.0
    static let paddingYElements: CGFloat = 3.0
    static let paddingYFloatLabel: CGFloat = 5.0
    static let cornerRadius: CGFloat = 5.0
    static let borderWidth: CGFloat = 2.0
    static let floatingPlaceholderFontSize: CGFloat = 16.0
    static let errorLabelFontSize: CGFloat = 14.0
    static let animationDuration: TimeInterval = 0.2
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
      updateErrorLabel()
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

  private var fontHeight: CGFloat {
    let font = font ?? .systemFont(ofSize: 18)
    return ceil(font.lineHeight)
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

  private var errorFontHeight: CGFloat {
    let font = errorLabel.font ?? .systemFont(ofSize: 14)
    return ceil(font.lineHeight)
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
  override public var validText: Bool {
    didSet { updateAppearance() }
  }

  override public var borderStyle: UITextField.BorderStyle {
    get { .none }
    set { super.borderStyle = .none }
  }

  override public var textAlignment: NSTextAlignment {
    get { .left }
    set { super.textAlignment = .left }
  }

  public override var clearButtonMode: UITextField.ViewMode {
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
    validText = true
    textAlignment = .left
    borderStyle = .none
    rightView = rightImageView
  }

  private func setupBackgroundLayer() {
    backgroundFrameLayer.cornerRadius = Constants.cornerRadius
    backgroundFrameLayer.borderWidth = Constants.borderWidth
    layer.insertSublayer(backgroundFrameLayer, at: 0)
  }

  private func setupFloatingPlaceholder() {
    floatingPlaceholderLabel.alpha = 0.0
    floatingPlaceholderLabel.font = .systemFont(ofSize: Constants.floatingPlaceholderFontSize)
    floatingPlaceholderLabel.numberOfLines = 1
    addSubview(floatingPlaceholderLabel)
  }

  private func setupErrorLabel() {
    errorLabel.font = .systemFont(ofSize: Constants.errorLabelFontSize)
    errorLabel.numberOfLines = 1
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

  // MARK: - Private Methods
  private func updateErrorLabel() {
    errorLabel.frame = CGRect(
      x: 0,
      y: frame.height - errorFontHeight,
      width: bounds.width - originX,
      height: errorFontHeight
    )
  }

  private func updateBackgroundLayer() {
    backgroundFrameLayer.frame = CGRect(
      x: 0,
      y: 0,
      width: frame.width,
      height: frame.height - errorFontHeight - Constants.paddingYElements
    )
  }

  private func updatePlaceholder(animated: Bool) {
    guard placeholder?.isEmpty ?? true else { return }
    let shouldFloat = isEditing || !(text?.isEmpty ?? true)
    toggleFloatingPlaceholder(toFloat: shouldFloat, animated: animated)
  }

  private func toggleFloatingPlaceholder(toFloat: Bool, animated: Bool) {
    floatingPlaceholderLabel.alpha = 1.0
    let newFrame = CGRect(
      x: originX,
      y: toFloat
        ? Constants.paddingYFloatLabel
        :
        (frame.height - floatingPlaceholderHeight - errorFontHeight - Constants.paddingYElements) /
        2,
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
      = (bounds.height - rect.size.height - errorFontHeight - Constants.paddingYElements) / 2
    rect.origin.x += Constants.paddingX
    return rect
  }

  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.y
      = (bounds.height - rect.size.height - errorFontHeight - Constants.paddingYElements) / 2
    rect.origin.x -= Constants.paddingX
    return rect
  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.clearButtonRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
    return rect
  }

  private func insetRectForBounds(rect: CGRect) -> CGRect {
    CGRect(
      x: originX,
      y: 0,
      width: rect.size.width - originX - Constants.paddingX,
      height: rect.height
    )
  }
}

// MARK: - Appearance
private extension LineTextField {
  func updateAppearance() {
    let errorColor = errorColor ?? .red
    let defaultColor = defaultColor ?? .darkText
    let placeholderColor = placeholderColor ?? .systemGray2
    let focusColor = UIColor.systemBlue

    errorLabel.textColor = errorColor

    switch (isFirstResponder, validText) {
    case (true, true): // focus and valid
      backgroundFrameLayer.borderColor = focusColor.cgColor
      backgroundFrameLayer.backgroundColor = UIColor.clear.cgColor
      floatingPlaceholderLabel.textColor = focusColor
      textColor = defaultColor
      rightImageView.tintColor = focusColor
    case (true, false): // focus and invalid
      backgroundFrameLayer.borderColor = errorColor.cgColor
      backgroundFrameLayer.backgroundColor = UIColor.clear.cgColor
      floatingPlaceholderLabel.textColor = errorColor
      textColor = errorColor
      rightImageView.tintColor = errorColor
    case (false, true): // not focus and valid
      backgroundFrameLayer.borderColor = UIColor.clear.cgColor
      backgroundFrameLayer.backgroundColor = placeholderColor.withAlphaComponent(0.5).cgColor
      floatingPlaceholderLabel.textColor = placeholderColor
      textColor = defaultColor
      rightImageView.tintColor = placeholderColor
    case (false, false): // not focus and invalid
      backgroundFrameLayer.borderColor = UIColor.clear.cgColor
      backgroundFrameLayer.backgroundColor = errorColor.withAlphaComponent(0.5).cgColor
      floatingPlaceholderLabel.textColor = errorColor
      textColor = errorColor
      rightImageView.tintColor = .clear
    }
  }
}
