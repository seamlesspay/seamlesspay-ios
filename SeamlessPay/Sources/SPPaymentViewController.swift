// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import Foundation

public protocol SPPaymentViewControllerDelegate: AnyObject {
  func paymentViewControllerChargeSuccess(
    _ viewController: SPPaymentViewController,
    charge: Charge
  )
  func paymentViewControllerChargeError(
    _ viewController: SPPaymentViewController,
    error: SeamlessPayError
  )
  func paymentViewControllerPaymentMethodSuccess(
    _ viewController: SPPaymentViewController,
    paymentMethod: PaymentMethod
  )
  func paymentViewControllerPaymentMethodError(
    _ viewController: SPPaymentViewController,
    error: SeamlessPayError
  )
}

public class SPPaymentViewController: UIViewController {
  public var paymentType: PaymentType = .creditCard
  public var paymentDescription: String?
  public var paymentAmount: Decimal = 0.0
  public var billingAddress: Address?
  public var logoImage: UIImage?
  public weak var delegate: SPPaymentViewControllerDelegate?

  var cardTextField = SPPaymentCardTextField()
  var payButton: UIButton?
  var amountLabel: UILabel?
  var descriptionLabel: UILabel?
  var activityIndicator = SPLoadingView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
  var isEditAmount: Bool = false
  var isVerification: Bool = false
  var idempotencyKey: String?
  var orderId: String?
  var name: String?
  var paymentMetadata: String?

  private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_US")

    return formatter
  }()

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white

    cardTextField.postalCodeEntryEnabled = true
    cardTextField.countryCode = "US"

    let button = UIButton(type: .custom)
    button.layer.cornerRadius = 5
    button.backgroundColor = UIColor.systemBlue
    button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    button.setTitle("Pay", for: .normal)
    button.addTarget(self, action: #selector(pay), for: .touchUpInside)
    payButton = button

    let amountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
    amountLabel.isUserInteractionEnabled = isEditAmount
    amountLabel.textColor = UIColor.darkGray
    let formattedAmount = formattedCurrency(paymentAmount)
    amountLabel.text = "Amount: \(formattedAmount)"
    self.amountLabel = amountLabel

    let descriptionLabel = UILabel()
    descriptionLabel.text = paymentDescription
    descriptionLabel.font = UIFont.systemFont(ofSize: 13)
    descriptionLabel.textColor = UIColor.gray
    descriptionLabel.numberOfLines = 2
    descriptionLabel.sizeToFit()
    self.descriptionLabel = descriptionLabel

    let logoImageView = UIImageView(image: logoImage)
    logoImageView.contentMode = .center

    let stackView = UIStackView(arrangedSubviews: [
      logoImageView,
      amountLabel,
      descriptionLabel,
      cardTextField,
      button,
    ])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 20
    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.leftAnchor.constraint(
        equalToSystemSpacingAfter: view.leftAnchor,
        multiplier: 2
      ),
      view.rightAnchor.constraint(
        equalToSystemSpacingAfter: stackView.rightAnchor,
        multiplier: 2
      ),
      stackView.topAnchor.constraint(
        equalToSystemSpacingBelow: view.topAnchor,
        multiplier: 2
      ),
    ])

    if let activityIndicator {
      activityIndicator.center = view.center
      activityIndicator.lineColor = UIColor.systemBlue
      view.addSubview(activityIndicator)
    }
  }

  private func formattedCurrency(_ value: Decimal) -> String {
    let formattedValue = NSDecimalNumber(decimal: value)
    formatter.numberStyle = .currency
    return formatter.string(from: formattedValue) ?? ""
  }

  private func formattedParameter(_ value: Decimal) -> String {
    let formattedValue = NSDecimalNumber(decimal: value)
    formatter.numberStyle = .decimal
    return formatter.string(from: formattedValue) ?? ""
  }
}

private extension SPPaymentViewController {
  @objc func pay() {
    activityIndicator?.startAnimation()

    APIClient.shared.tokenize(
      paymentType: paymentType,
      accountNumber: cardTextField.cardNumber ?? "",
      expDate: .init(month: cardTextField.expirationMonth, year: cardTextField.expirationYear),
      cvv: cardTextField.cvc,
      accountType: nil,
      routing: nil,
      pin: nil,
      billingAddress: billingAddress,
      name: name
    ) { result in

      switch result {
      case let .success(paymentMethod):
        DispatchQueue.main.async {
          self.delegate?.paymentViewControllerPaymentMethodSuccess(
            self,
            paymentMethod: paymentMethod
          )
        }

        APIClient.shared.createCharge(
          token: paymentMethod.token,
          cvv: self.cardTextField.cvc,
          capture: true,
          currency: nil,
          amount: self.formattedParameter(self.paymentAmount),
          taxAmount: nil,
          taxExempt: false,
          tip: nil,
          surchargeFeeAmount: nil,
          description: self.paymentDescription,
          order: nil,
          orderID: self.orderId,
          poNumber: nil,
          metadata: self.paymentMetadata,
          descriptor: nil,
          entryType: nil,
          idempotencyKey: self.idempotencyKey
        ) { result in

          DispatchQueue.main.async {
            self.activityIndicator?.stopAnimation()

            switch result {
            case let .success(charge):
              self.delegate?.paymentViewControllerChargeSuccess(self, charge: charge)
            case let .failure(error):
              self.delegate?.paymentViewControllerChargeError(self, error: error)
            }
          }
        }
      case let .failure(error):
        DispatchQueue.main.async {
          self.activityIndicator?.stopAnimation()
          self.delegate?.paymentViewControllerPaymentMethodError(self, error: error)
        }
      }
    }
  }
}
