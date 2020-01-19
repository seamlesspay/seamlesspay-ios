/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

import SeamlessPayCore

class ViewController: UIViewController {
    lazy var cardTextField: SPPaymentCardTextField = {
        let cardTextField = SPPaymentCardTextField()
        return cardTextField
    }()

    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 20),
        ])
    }

    @objc
    func pay() {
        SPAPIClient.getSharedInstance()?.createPaymentMethod(
            withType: "CREDIT_CARD",
            account: cardTextField.cardNumber,
            expDate: cardTextField.formattedExpirationDate,
            accountType: nil,
            routing: nil,
            pin: nil,
            address: nil,
            address2: nil,
            city: nil,
            country: nil,
            state: nil,
            zip: cardTextField.postalCode,
            company: nil,
            email: nil,
            phone: nil,
            name: nil,
            nickname: nil, success: { (paymentMethod: SPPaymentMethod?) in

                let token = paymentMethod?.token

                SPAPIClient.getSharedInstance()?.createCharge(
                    withToken: token!,
                    cvv: self.cardTextField.cvc,
                    capture: true,
                    currency: nil,
                    amount: "1",
                    taxAmount: nil,
                    taxExempt: false,
                    tip: nil,
                    surchargeFeeAmount: nil,
                    scheduleIndicator: nil,
                    description: nil,
                    order: nil,
                    orderId: nil,
                    poNumber: nil,
                    metadata: nil,
                    descriptor: nil,
                    txnEnv: nil,
                    achType: nil,
                    credentialIndicator: nil,
                    transactionInitiation: nil,
                    idempotencyKey: nil,
                    needSendReceipt: false,
                    success: { (charge: SPCharge?) in

                        // Success Charge:
                        print(charge?.chargeId ?? "charge is nil")

                    }, failure: { (error: SPError?) in

                        // Handle the error
                        print(error?.localizedDescription ?? "")
                        return
                    }
                )

            }, failure: { (error: SPError?) in

                // Handle the error
                print(error?.localizedDescription ?? "")
                return
            }
        )
    }
}
