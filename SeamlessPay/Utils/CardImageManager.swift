// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

class CardImageManager {
  // MARK: Interface
  enum Field {
    case number
    case cvc
  }

  func updateImageView(
    _ lineTextField: LineTextField,
    for field: CardImageManager.Field,
    brand: SPCardBrand,
    brandImageSet: SPCardBrandImageSet,
    isValid: Bool
  ) {
    let image = image(for: field, brand: brand, brandImageSet: brandImageSet, isValid: isValid)
    updateImageViewIfNeeded(lineTextField, image: image)
  }

  // MARK: Private
  func image(
    for field: CardImageManager.Field,
    brand: SPCardBrand,
    brandImageSet: SPCardBrandImageSet,
    isValid: Bool
  ) -> UIImage? {
    switch isValid {
    case false:
      return getErrorImage()
    case true:
      switch field {
      case .number:
        return getNumberFieldImage(brand: brand, brandImageSet: brandImageSet)
      case .cvc:
        return getCVCFieldImage(brand: brand)
      }
    }
  }
}

private extension CardImageManager {
  func getErrorImage() -> UIImage? {
    SPImageLibrary.renewed_errorImageTemplate()
  }

  func getNumberFieldImage(
    brand: SPCardBrand,
    brandImageSet: SPCardBrandImageSet
  ) -> UIImage? {
    guard brand != .unknown else {
      return nil
    }
    return SPImageLibrary.renewed_brandImage(for: brand, imageSet: brandImageSet)
  }

  func getCVCFieldImage(brand: SPCardBrand) -> UIImage? {
    SPImageLibrary.renewed_cvcImageTemplate(for: brand)
  }

  func updateImageViewIfNeeded(_ lineTextField: LineTextField, image: UIImage?) {
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
