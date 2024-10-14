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
  private enum ImagedField {
    case number
    case cvc
  }

  func updateCardNumberImageView(
    _ imageView: UIImageView,
    brand: SPCardBrand,
    validation: SPCardValidationState
  ) {
    let image = image(for: .number, brand: brand, validation: validation)
    updateImageViewIfNeeded(imageView, image: image)
  }

  func updateCVCImageView(
    _ imageView: UIImageView,
    brand: SPCardBrand,
    validation: SPCardValidationState
  ) {
    let image = image(for: .cvc, brand: brand, validation: validation)
    updateImageViewIfNeeded(imageView, image: image)
  }

  private func image(
    for field: ImagedField,
    brand: SPCardBrand,
    validation: SPCardValidationState
  ) -> UIImage? {
    guard validation != .invalid else {
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

  private func updateImageViewIfNeeded(_ imageView: UIImageView, image: UIImage?) {
    guard imageView.image != image else {
      return
    }

    UIView.transition(
      with: imageView,
      duration: 0.2,
      options: [.curveEaseInOut, .transitionCrossDissolve],
      animations: { imageView.image = image },
      completion: nil
    )
  }
}
