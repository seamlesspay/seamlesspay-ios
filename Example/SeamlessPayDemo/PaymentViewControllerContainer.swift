// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import SeamlessPayCore

class PaymentViewControllerContainer: UIViewController, SPPaymentViewControllerDelegate {
  var paymentViewController: SPPaymentViewController?

  override func viewDidLoad() {
    super.viewDidLoad()

    let button = UIButton(type: .custom)
    button.layer.cornerRadius = 5
    button.backgroundColor = UIColor.black
    button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    button.setTitle("SPPaymentViewController", for: .normal)
    button.addTarget(self, action: #selector(presentPaymentModal), for: .touchUpInside)
    button.sizeToFit()
    button.center = view.center

    view.addSubview(button)
  }

  @objc func presentPaymentModal() {
    let billingAddress = SPAddress(
      line1: nil,
      line2: nil,
      city: nil,
      country: "US",
      state: nil,
      postalCode: "12345"
    )

    let customer = SPCustomer(
      name: "Test name",
      email: nil,
      phone: nil,
      companyName: nil,
      notes: nil,
      website: nil,
      metadata: nil,
      address: nil,
      paymentMethods: nil
    )

    let paymentVC = SPPaymentViewController(nibName: nil, bundle: nil)
    paymentVC.paymentDescription = "Order payment description"
    paymentVC.logoImage = UIImage(named: "Icon-72.png")
    paymentVC.paymentAmount = 10.2
    paymentVC.billingAddress = billingAddress
    paymentVC.customer = customer
    paymentVC.delegate = self
    paymentVC.paymentType = .creditCard
    paymentViewController = paymentVC

    present(paymentVC, animated: true, completion: nil)
  }

  // MARK: SPPaymentViewControllerDelegate

  func paymentViewControllerPaymentMethodSuccess(
    _ viewController: SeamlessPayCore.SPPaymentViewController,
    paymentMethod: PaymentMethod
  ) {}

  func paymentViewControllerChargeSuccess(
    _ viewController: SeamlessPayCore.SPPaymentViewController,
    charge: SeamlessPayCore.Charge
  ) {
    let success =
      """
      Amount: $\(charge.amount ?? "")
      Status: \(charge.status ?? "")
      Status message: \(charge.statusDescription ?? "")
      txnID #: \(charge.id ?? "")
      """
    displayAlertWithTitle("Success", message: success)
  }

  func paymentViewControllerPaymentMethodError(
    _ viewController: SeamlessPayCore.SPPaymentViewController,
    error: SeamlessPayCore.SeamlessPayError
  ) {
    displayAlertWithTitle("Error", message: error.localizedDescription)
  }

  func paymentViewControllerChargeError(
    _ viewController: SeamlessPayCore.SPPaymentViewController,
    error: SeamlessPayCore.SeamlessPayError
  ) {
    displayAlertWithTitle("Error", message: error.localizedDescription)
  }

  func displayAlertWithTitle(_ title: String, message: String) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self.paymentViewController?.present(alert, animated: true, completion: nil)
    }
  }
}
