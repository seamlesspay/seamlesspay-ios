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
  private var floatingPlaceholderFont: UIFont = .systemFont(ofSize: 16)

  private let paddingX: CGFloat = 10.0
  private let paddingYText: CGFloat = 3.0

  private var borderColor: UIColor = .systemGray2
  private var borderWidth: CGFloat = 2

  private var borderLayer: CALayer = .init()

  private var paddingYFloatLabel: CGFloat = 5.0

  private var originX: CGFloat {
    if let leftView = leftView {
      return leftView.frame.origin.x + leftView.bounds.size.width + paddingX
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

  private var isFirsResponderTransition: Bool = false

  public var floatingPlaceholder: String? {
    set {
      floatingPlaceholderLabel.text = newValue
    }
    get {
      return floatingPlaceholderLabel.text
    }
  }

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

    borderLayer.cornerRadius = 7
    borderLayer.borderWidth = borderWidth
    borderLayer.borderColor = borderColor.cgColor

    floatingPlaceholderLabel.frame = CGRect.zero
    floatingPlaceholderLabel.alpha = 0.0
    floatingPlaceholderLabel.font = floatingPlaceholderFont
    floatingPlaceholderLabel.text = floatingPlaceholder

    addSubview(floatingPlaceholderLabel)

    layer.insertSublayer(borderLayer, at: 0)
  }

  private func floatingPlaceholderHeight() -> CGFloat {
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

  private func updatePlaceholder(animated: Bool) {
    guard placeholder == .none || placeholder?.isEmpty == true else {
      return
    }

    let toFloat = isEditing || text?.isEmpty == false

    toggleFloatingLabel(toFloat: toFloat, animated: animated)
  }

  private func toggleFloatingLabel(toFloat: Bool, animated: Bool) {
    floatingPlaceholderLabel.alpha = 1.0

    let transformations: (() -> Void) = {
      if toFloat {
        self.floatingPlaceholderLabel.frame = CGRect(
          x: self.originX,
          y: self.paddingYFloatLabel,
          width: self.floatLabelWidth,
          height: self.floatingPlaceholderHeight()
        )

      } else {
        self.floatingPlaceholderLabel.frame = CGRect(
          x: self.originX,
          y: self.frame.height / 2 - self.floatingPlaceholderHeight() / 2,
          width: self.floatLabelWidth,
          height: self.floatingPlaceholderHeight()
        )
      }
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
    let topInset =
      paddingYFloatLabel + floatingPlaceholderHeight() + paddingYText
    let textOriginalY = (rect.height - fontHeight) / 2.0
    var textY = topInset - textOriginalY

    if textY < 0 {
      textY = topInset
    }

    return CGRect(
      x: originX,
      y: ceil(textY),
      width: rect.size.width - originX - paddingX,
      height: rect.height
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

  override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.leftViewRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
    rect.origin.x = rect.origin.x + paddingX
    return rect
  }

  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.rightViewRect(forBounds: bounds)
    rect.origin.y = (bounds.height - rect.size.height) / 2
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

    borderLayer.frame = CGRect(
      x: bounds.origin.x,
      y: bounds.origin.y,
      width: bounds.width,
      height: bounds.height
    )

//    let floatingLabelSize = floatingPlaceholderLabel.sizeThatFits(bounds.size)
//
//    floatingPlaceholderLabel.frame = CGRect(
//      x: paddingX,
//      y: floatingPlaceholderLabel.frame.origin.y,
//      width: floatingLabelSize.width,
//      height: floatingLabelSize.height
//    )

    floatingPlaceholderLabel.textColor = isFirstResponder
      ? floatingPlaceholderActiveColor
      : floatingPlaceholderColor

    if !isFirsResponderTransition {
      updatePlaceholder(animated: false)
    }
  }

  @objc override public func becomeFirstResponder() -> Bool {
    let result = super.becomeFirstResponder()
    isFirsResponderTransition = true
    updatePlaceholder(animated: true)
    isFirsResponderTransition = false
    return result
  }

  @objc override public func resignFirstResponder() -> Bool {
    let result = super.resignFirstResponder()
    isFirsResponderTransition = true
    updatePlaceholder(animated: true)
    isFirsResponderTransition = false
    return result
  }
}
