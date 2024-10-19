// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

public class LineTextField: SPFormTextField {
  // MARK: Views
  private let floatingPlaceholderLabel: UILabel = .init()
  private let errorLabel: UILabel = .init()

  // MARK: Layers
  private let backgroundFrameLayer: CALayer = .init()

  // MARK: Constants
  private let paddingX: CGFloat = 10.0
  private let paddingYElements: CGFloat = 3.0
  private let paddingYFloatLabel: CGFloat = 5.0

  // MARK: Variables
  private var isFirsResponderTransition: Bool = false

  private var originX: CGFloat {
    guard let leftView = leftView else {
      return paddingX
    }
    return leftView.frame.maxX + paddingX
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

  private var errorHeight: CGFloat {
    errorFontHeight
  }

  private var floatingPlaceholderWidth: CGFloat {
    var width = bounds.width

    if let leftViewWidth = leftView?.bounds.width {
      width -= leftViewWidth
    }

    if let rightViewWidth = rightView?.bounds.width {
      width -= rightViewWidth
    }

    return width - (originX * 2)
  }

  // MARK: Overrides
  override public var validText: Bool {
    get {
      return super.validText
    }
    set {
      super.validText = newValue
      updateAppearance()
    }
  }

  override public var borderStyle: UITextField.BorderStyle {
    get {
      return super.borderStyle
    }
    set {
      super.borderStyle = .none
    }
  }

  override public var textAlignment: NSTextAlignment {
    get {
      return super.textAlignment
    }
    set {
      super.textAlignment = .left
    }
  }

  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    let rect = super.textRect(forBounds: bounds)
    return insetRectForBounds(rect: rect)
  }

  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    let rect = super.editingRect(forBounds: bounds)
    return insetRectForBounds(rect: rect)
  }

  override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.leftViewRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height - errorHeight - paddingYElements) / 2
    rect.origin.x = rect.origin.x + paddingX
    return rect
  }

  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height - errorHeight - paddingYElements) / 2
    rect.origin.x = rect.origin.x - paddingX
    return rect
  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.clearButtonRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
    return rect
  }

  @objc override public func layoutSubviews() {
    super.layoutSubviews()
    if !isFirsResponderTransition {
      updatePlaceholder(animated: false)
    }

    updateErrorLabel()
    updateBackgroundLayer()
  }

  @objc override public func becomeFirstResponder() -> Bool {
    let result = super.becomeFirstResponder()
    isFirsResponderTransition = true
    updatePlaceholder(animated: true)
    updateAppearance()
    isFirsResponderTransition = false
    return result
  }

  @objc override public func resignFirstResponder() -> Bool {
    let result = super.resignFirstResponder()
    isFirsResponderTransition = true
    updatePlaceholder(animated: true)
    updateAppearance()
    isFirsResponderTransition = false
    return result
  }

  // MARK: - Initializers
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  // MARK: - Public Methods
  public var floatingPlaceholder: String? {
    set {
      floatingPlaceholderLabel.text = newValue
    }
    get {
      return floatingPlaceholderLabel.text
    }
  }

  public var errorMessage: String? {
    didSet {
      errorLabel.text = errorMessage
      toggleErrorLabel()
    }
  }

  public lazy var rightImageView: UIImageView = {
    let imageView = UIImageView(image: nil)
    imageView.contentMode = .center
    imageView.backgroundColor = .clear
    imageView.tintColor = placeholderColor
    imageView.isUserInteractionEnabled = false

    return imageView
  }()

  override public var rightView: UIView? {
    set {
      super.rightView = rightImageView
    }
    get {
      return super.rightView
    }
  }

  // MARK: - Private Methods
  private func commonInit() {
    validText = true
    textAlignment = .left
    borderStyle = .none
    rightView = rightImageView

    backgroundFrameLayer.cornerRadius = 5.0
    backgroundFrameLayer.borderWidth = 2.0

    layer.insertSublayer(backgroundFrameLayer, at: 0)

    floatingPlaceholderLabel.alpha = 0.0
    floatingPlaceholderLabel.font = .systemFont(ofSize: 16)
    floatingPlaceholderLabel.text = floatingPlaceholder
    floatingPlaceholderLabel.numberOfLines = 1
    addSubview(floatingPlaceholderLabel)

    errorLabel.font = .systemFont(ofSize: 14)
    errorLabel.text = errorMessage
    errorLabel.numberOfLines = 1
    addSubview(errorLabel)

    updateAppearance()
  }

  private func toggleErrorLabel() {
    errorLabel.isHidden = errorMessage?.isEmpty == true
  }

  private func updateErrorLabel() {
    errorLabel.frame = .init(
      x: 0,
      y: frame.height - errorHeight,
      width: floatingPlaceholderWidth,
      height: errorHeight
    )
    toggleErrorLabel()
  }

  private func updateBackgroundLayer() {
    backgroundFrameLayer.frame = .init(
      x: 0,
      y: 0,
      width: frame.width,
      height: frame.height - errorHeight - paddingYElements
    )
  }

  private func updatePlaceholder(animated: Bool) {
    guard placeholder == .none || placeholder?.isEmpty == true else {
      return
    }

    let toFloat = isEditing || text?.isEmpty == false

    toggleFloatingPlaceholder(toFloat: toFloat, animated: animated)
  }

  private func toggleFloatingPlaceholder(toFloat: Bool, animated: Bool) {
    floatingPlaceholderLabel.alpha = 1.0

    let floatingPlaceholderNewFrame = CGRect(
      x: originX,
      y: toFloat
        ? paddingYFloatLabel
        : (frame.height - floatingPlaceholderHeight - errorHeight - paddingYElements) / 2,
      width: floatingPlaceholderWidth,
      height: floatingPlaceholderHeight
    )
    let transformations: (() -> Void) = {
      self.floatingPlaceholderLabel.frame = floatingPlaceholderNewFrame
    }

    if animated {
      UIView.animate(
        withDuration: 0.2,
        delay: 0.0,
        options: [
          .beginFromCurrentState,
          .curveEaseIn,
        ],
        animations: transformations
      ) { status in
        DispatchQueue.main.async {
          self.layoutIfNeeded()
        }
      }
    } else {
      transformations()
    }
  }

  private func insetRectForBounds(rect: CGRect) -> CGRect {
    return CGRect(
      x: originX,
      y: 0,
      width: rect.size.width - originX - paddingX,
      height: rect.height
    )
  }
}

private extension LineTextField {
  func updateAppearance() {
    let errorColor = errorColor ?? UIColor.red
    let defaultColor = defaultColor ?? UIColor.darkText
    let placeholderColor = placeholderColor ?? UIColor.systemGray2
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
      backgroundFrameLayer.backgroundColor = errorColor.withAlphaComponent(0.5).cgColor

      floatingPlaceholderLabel.textColor = errorColor
      textColor = errorColor

      rightImageView.tintColor = .clear
    case (false, true): // not focus and valid
      backgroundFrameLayer.borderColor = UIColor.clear.cgColor
      backgroundFrameLayer.backgroundColor = placeholderColor.withAlphaComponent(0.5).cgColor

      floatingPlaceholderLabel.textColor = placeholderColor
      textColor = defaultColor

      rightImageView.tintColor = placeholderColor
    case(false, false): // not focus and invalid
      backgroundFrameLayer.borderColor = UIColor.clear.cgColor
      backgroundFrameLayer.backgroundColor = errorColor.withAlphaComponent(0.5).cgColor

      floatingPlaceholderLabel.textColor = errorColor
      textColor = errorColor

      rightImageView.tintColor = .clear
    }
  }
}
