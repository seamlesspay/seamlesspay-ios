// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

import UIKit
import Foundation

class MultiLineCardImageManager {

  // MARK: Interface
  enum Field {
    case number
    case cvc
  }

  func updateImageView(
    _ lineTextField: LineTextField,
    for field: MultiLineCardImageManager.Field,
    brand: SPCardBrand,
    isValid: Bool
  ) {
    let image = image(for: field, brand: brand, isValid: isValid)
    updateImageViewIfNeeded(lineTextField, image: image)
  }

  // MARK: Private
  private func image(
    for field: MultiLineCardImageManager.Field,
    brand: SPCardBrand,
    isValid: Bool
  ) -> UIImage? {
    guard isValid else {
      return SPImageLibrary.renewed_errorImage()
    }

    switch field {
    case .number:
      switch brand {
      case .unknown:
        return nil
      default:
        return SPImageLibrary.renewed_brandImage(for: brand)
      }
    case .cvc:
      return SPImageLibrary.renewed_cvcImageTemplate(for: brand)
    }
  }

  private func updateImageViewIfNeeded(_ lineTextField: LineTextField, image: UIImage?) {
    guard lineTextField.rightImageView.image != image else {
      return
    }

    UIView.transition(
      with: lineTextField,
      duration: 0.2,
      options: [.curveEaseInOut, .transitionCrossDissolve],
      animations: { lineTextField.rightImageView.image = image },
      completion: .none
    )
    lineTextField.layoutSubviews()
  }
}
