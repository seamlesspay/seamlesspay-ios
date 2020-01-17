//
//  ViewController.swift
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

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
        let successBlock: (SPPaymentMethod) -> Void = { paymentMethod in
            SPAPIClient.getSharedInstance().createCharge(
                withToken: paymentMethod.token,
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
                success: { charge in
                    print(charge.chargeId ?? "No Charge ID")
                },
                failure: { failure in

                } )
        }

        // Pass it to SPAPIClient to create a Token
        SPAPIClient.getSharedInstance().createPaymentMethod(
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
            nickname: nil,
            success: successBlock,
            failure: { failure in print("ERROR: ", failure) }
        )
    }
}

