// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

public class LineTextField: SPFormTextField {
  private var floatingPlaceholderLabel: UILabel = .init()
  private var floatingPlaceholderColor: UIColor = .systemGray2
  private var floatingPlaceholderActiveColor: UIColor = .systemGray2
  private var floatingLabelShowAnimationDuration = 0.3

  private let paddingX: CGFloat = 5.0
  private let paddingHeight: CGFloat = 10.0

  private var borderColor: UIColor = .systemGray2
  private var borderLayer: CALayer = .init()
  private var borderWidth: CGFloat = 2

  private var internalLayer: CALayer = .init()

  private var animateFloatPlaceholder: Bool = true

  private var paddingYFloatLabel: CGFloat = 3.0 {
    didSet {
      invalidateIntrinsicContentSize()
    }
  }

  private var originX: CGFloat {
    if let leftView = leftView {
      return leftView.frame.origin.x + leftView.bounds.size.width - paddingX
    }

    return paddingX
  }

  private var fontHeight: CGFloat {
    let font = font ?? .systemFont(ofSize: 18)
    return ceil(font.lineHeight)
  }

  private var floatLabelWidth: CGFloat {
    var width = bounds.size.width

    if let leftViewWidth = leftView?.bounds.size.width {
      width -= leftViewWidth
    }

    if let rightViewWidth = rightView?.bounds.size.width {
      width -= rightViewWidth
    }

    return width - (originX * 2)
  }

  private var isFloatLabelShowing: Bool = false

  override public var borderStyle: UITextField.BorderStyle {
    didSet {
      guard borderStyle != oldValue else { return }
      borderStyle = .none
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

  override public var placeholder: String? {
    didSet {
      floatingPlaceholderLabel.text = placeholder
    }
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    textAlignment = .left

    internalLayer.cornerRadius = 7
    internalLayer.borderWidth = borderWidth
    internalLayer.borderColor = borderColor.cgColor

    floatingPlaceholderLabel.frame = CGRect.zero
    floatingPlaceholderLabel.alpha = 0.0
    floatingPlaceholderLabel.font = UIFont.systemFont(ofSize: 14.0)
    floatingPlaceholderLabel.text = placeholder

    addSubview(floatingPlaceholderLabel)

    layer.insertSublayer(internalLayer, at: 0)
  }

  func setFloatLabelAlignment() {
    floatingPlaceholderLabel.frame.origin.x = paddingX
  }

  private func showFloatingLabel(_ animated: Bool) {
    let animations: (() -> Void) = {
      self.floatingPlaceholderLabel.alpha = 1.0

      self.floatingPlaceholderLabel.frame = CGRect(
        x: self.floatingPlaceholderLabel.frame.origin.x,
        y: self.paddingYFloatLabel,
        width: self.floatingPlaceholderLabel.bounds.size.width,
        height: self.floatingPlaceholderLabel.bounds.size.height
      )
    }

    if animated && animateFloatPlaceholder {
      UIView.animate(
        withDuration: floatingLabelShowAnimationDuration,
        delay: 0.0,
        options: [
          .beginFromCurrentState,
          .curveEaseOut,
        ],
        animations: animations
      ) { status in
        DispatchQueue.main.async {
          self.layoutIfNeeded()
        }
      }
    } else {
      animations()
    }
  }

  private func hideFloatingLabel(_ animated: Bool) {
    let animations: (() -> Void) = {
      self.floatingPlaceholderLabel.alpha = 0.0

      self.floatingPlaceholderLabel.frame = CGRect(
        x: self.floatingPlaceholderLabel.frame.origin.x,
        y: self.floatingPlaceholderLabel.font.lineHeight,
        width: self.floatingPlaceholderLabel.bounds.size.width,
        height: self.floatingPlaceholderLabel.bounds.size.height
      )
    }

    if animated && animateFloatPlaceholder {
      UIView.animate(
        withDuration: floatingLabelShowAnimationDuration,
        delay: 0.0,
        options: [
          .beginFromCurrentState,
          .curveEaseOut,
        ],
        animations: animations
      ) { status in
        DispatchQueue.main.async {
          self.layoutIfNeeded()
        }
      }
    } else {
      animations()
    }
  }

  private func insetRectForEmptyBounds(rect: CGRect) -> CGRect {
    let newX = originX

    return CGRect(
      x: newX,
      y: 0,
      width: rect.width - newX - paddingX,
      height: rect.height
    )
  }

  private func insetRectForBounds(rect: CGRect) -> CGRect {
    guard let placeholderText = floatingPlaceholderLabel.text, !placeholderText.isEmpty else {
      return insetRectForEmptyBounds(rect: rect)
    }

    if let text = text, text.isEmpty {
      return insetRectForEmptyBounds(rect: rect)
    } else {
      let topInset =
        paddingYFloatLabel + floatingPlaceholderLabel.bounds.size.height + (paddingHeight / 2.0)
      let textOriginalY = (rect.height - fontHeight) / 2.0
      var textY = topInset - textOriginalY

      if textY < 0 {
        textY = topInset
      }
      let newX = originX

      return CGRect(
        x: newX,
        y: ceil(textY),
        width: rect.size.width - newX - paddingX,
        height: rect.height
      )
    }
  }

  override public var intrinsicContentSize: CGSize {
    self.layoutIfNeeded()

    let textFieldIntrinsicContentSize = super.intrinsicContentSize

    return CGSize(
      width: textFieldIntrinsicContentSize.width,
      height: textFieldIntrinsicContentSize.height + paddingYFloatLabel + floatingPlaceholderLabel
        .bounds.size.height + paddingHeight
    )
  }

  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    let rect = super.textRect(forBounds: bounds)
    return insetRectForBounds(rect: rect)
  }

  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    let rect = super.editingRect(forBounds: bounds)
    return insetRectForBounds(rect: rect)
  }

  private func insetForSideView(forBounds bounds: CGRect) -> CGRect {
    var rect = bounds
    rect.origin.y = 0
    rect.size.height = bounds.height
    return rect
  }

//  override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//    let rect = super.leftViewRect(forBounds: bounds)
//    return insetForSideView(forBounds: rect)
//  }

//  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//    let rect = super.rightViewRect(forBounds: bounds)
//    return insetForSideView(forBounds: rect)
//  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.clearButtonRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
    return rect
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    CATransaction.begin()
    CATransaction.setDisableActions(true)

    internalLayer.frame = CGRect(
      x: bounds.origin.x,
      y: bounds.origin.y,
      width: bounds.width,
      height: bounds.height
    )

    CATransaction.commit()

    let floatingLabelSize = floatingPlaceholderLabel.sizeThatFits(bounds.size)

    floatingPlaceholderLabel.frame = CGRect(
      x: originX,
      y: floatingPlaceholderLabel.frame.origin.y,
      width: floatingLabelSize.width,
      height: floatingLabelSize.height
    )

    setFloatLabelAlignment()

    floatingPlaceholderLabel.textColor = isFirstResponder
      ? floatingPlaceholderActiveColor
      : floatingPlaceholderColor

    if let enteredText = text, !enteredText.isEmpty {
      showFloatingLabel(isFirstResponder)
    } else {
      hideFloatingLabel(isFirstResponder)
    }
  }
}
