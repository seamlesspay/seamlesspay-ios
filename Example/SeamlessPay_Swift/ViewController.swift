/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

import SeamlessPayCore
import PassKit

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
        
        let billingAddress = SPAddress.init(
            line1: nil,
            line2: nil,
            city: nil,
            country: nil,
            state: nil,
            postalCode: cardTextField.postalCode)
        
        
        SPAPIClient.getSharedInstance().createPaymentMethod(
            withPaymentType: "credit_card",
            account: cardTextField.cardNumber,
            expDate: cardTextField.formattedExpirationDate,
            cvv: self.cardTextField.cvc,
            accountType: nil,
            routing: nil,
            pin: nil,
            billingAddress: billingAddress,
            billingCompanyName: nil,
            accountEmail: nil,
            phoneNumber: nil,
            name: "Name IOS test", customer: nil,
            success: { (paymentMethod: SPPaymentMethod?) in
                
                let token = paymentMethod?.token
                
                SPAPIClient.getSharedInstance().createCharge(
                    withToken: token!,
                    cvv: self.cardTextField.cvc,
                    capture: true, currency: nil,
                    amount: "1",
                    taxAmount: nil,
                    taxExempt: false,
                    tip: nil,
                    surchargeFeeAmount: nil,
                    description: nil,
                    order: nil,
                    orderId: nil,
                    poNumber: nil,
                    metadata: nil,
                    descriptor: nil,
                    entryType: nil,
                    idempotencyKey: nil,
                    digitalWalletProgramType: nil,
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
