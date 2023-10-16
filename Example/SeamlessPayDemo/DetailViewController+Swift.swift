// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import SeamlessPayCore

extension DetailViewController {
  private func environmentFromString(_ string: String) -> Environment {
    switch string {
    case "production":
      return .production
    case "staging":
      return .staging
    case "sandbox":
      return .sandbox
    case "qat":
      return .qat
    default:
      return .sandbox
    }
  }

  private func paymentTypeFromString(_ string: String) -> PaymentType {
    switch string {
    case "credit_card":
      return .creditCard
    case "pldebit_card":
      return .plDebitCard
    case "gift_card":
      return .giftCard
    case "ach":
      return .ach
    default:
      return .creditCard
    }
  }

  func expDateFromString(_ string: String) -> ExpirationDate {
    let expElements = string
      .components(separatedBy: "/")
      .map { UInt($0) }
      .compactMap { $0 }

    guard expElements.count >= 2 else {
      return .init(month: 0, year: 0)
    }
    return .init(month: expElements[0], year: expElements[1])
  }

  @objc func shouldStartDecidePolicy(_ request: URLRequest) -> Bool {
    guard
      let absoluteString = request.url?.absoluteString.removingPercentEncoding else {
      return true
    }

    let str = absoluteString
      .replacingOccurrences(of: "=", with: "&")
      .replacingOccurrences(of: "?", with: "&")
      .replacingOccurrences(of: "+", with: " ")

    let qa = str.components(separatedBy: "&")

    if qa.count == 1 {
      return true
    }

    if detailItem == "Authentication" {
      let publishableKey = qa[2]
      let secretKey = qa[4]
      let envSting = qa[6]
      let env = environmentFromString(envSting)

      UserDefaults.standard.set(publishableKey, forKey: "publishableKey")
      UserDefaults.standard.set(secretKey, forKey: "secretkey")
      UserDefaults.standard.set(env.rawValue, forKey: "env")

      APIClient.shared.set(
        secretKey: secretKey,
        publishableKey: publishableKey,
        environment: env
      )

      let updateWebView: (String) -> Void = { message in
        let html = self.authContentHTML(
          resultMessage: message,
          secretKey: secretKey,
          publishableKey: publishableKey,
          environment: env
        )
        self.webView.loadHTMLString(html, baseURL: nil)
      }

      APIClient.shared.listCharges { result in
        switch result {
        case .success:
          updateWebView("Authentication success!")
        case let .failure(error):
          print(error)
          updateWebView(error.localizedDescription)
        }
      }

      return false
    } else if ["Add Credit/Debit Card", "Add Gift Card", "Add ACH"].contains(detailItem) {
      let billingAddress = SPAddress(
        line1: qa[14],
        line2: qa[16],
        city: qa[18],
        country: qa[20],
        state: qa[22],
        postalCode: qa[24]
      )

      APIClient.shared.tokenize(
        paymentType: paymentTypeFromString(qa[2]),
        accountNumber: qa[4],
        expDate: expDateFromString(qa[6]),
        cvv: qa[8],
        accountType: qa[10],
        routing: qa[8],
        pin: qa[12],
        billingAddress: billingAddress,
        name: qa[26]
      ) { result in
        switch result {
        case let .success(paymentMethod):
          UserDefaults.standard.set(paymentMethod.dictionary(), forKey: "paymentMethod")

          let paymentMethodInfo = """
          Token info:<br>\(paymentMethod.token ?? "")<br>\
          \(paymentMethod.paymentType ?? "")<br>\
          \(paymentMethod.lastfour ?? "")<br>\
          \(paymentMethod.expDate ?? "")<br>
          """

          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: paymentMethodInfo
          )

          self.webView.loadHTMLString(html, baseURL: nil)
        case let .failure(error):
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false

    } else if detailItem == "Create Customer" {
      var paymentMethods: [SPPaymentMethod] = []
      if let savedPaymentMethod = UserDefaults.standard.dictionary(forKey: "paymentMethod") {
        paymentMethods.append(SPPaymentMethod(dictionary: savedPaymentMethod))
      }

      let address = SPAddress(
        line1: qa[6],
        line2: qa[8],
        city: qa[10],
        country: qa[12],
        state: qa[14],
        postalCode: qa[16]
      )

      APIClient.shared.createCustomer(
        name: qa[2],
        email: qa[4],
        address: address,
        companyName: qa[18],
        notes: nil,
        phone: qa[20],
        website: qa[22],
        paymentMethods: paymentMethods,
        metadata: "{\"customOption\":\"example\"}"
      ) { result in
        switch result {
        case let .success(customer):
          UserDefaults.standard.set(customer.dictionary(), forKey: "customer")
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: customer.customerId ?? ""
          )
          self.webView.loadHTMLString(html, baseURL: nil)
        case let .failure(error):
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if detailItem == "Retrieve a Customer" {
      APIClient.shared.retrieveCustomer(id: qa[2]) { result in
        switch result {
        case let .success(customer):
          UserDefaults.standard.set(customer.dictionary(), forKey: "customer")
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "Customer Name: \(customer.name)"
          )
          html = String(format: html, customer.customerId ?? "")
          self.webView.loadHTMLString(html, baseURL: nil)
        case let .failure(error):
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if detailItem == "Update Customer" {
      let address = SPAddress(
        line1: qa[6],
        line2: qa[8],
        city: qa[10],
        country: qa[12],
        state: qa[14],
        postalCode: qa[16]
      )

      APIClient.shared.updateCustomer(
        id: qa[24],
        name: qa[2],
        email: qa[4],
        address: address,
        companyName: qa[18],
        notes: nil,
        phone: qa[20],
        website: qa[22],
        paymentMethods: nil,
        metadata: "{\"customOption\":\"exampleupdate\"}"
      ) { result in
        switch result {
        case let .success(customer):
          let dict = customer.dictionary
          UserDefaults.standard.set(dict, forKey: "customer")

          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "Updated success!"
          )
          html = String(
            format: html,
            customer.name,
            customer.email ?? "",
            customer.address?.line1 ?? "",
            customer.address?.line2 ?? "",
            customer.address?.city ?? "",
            customer.address?.country ?? "",
            customer.address?.state ?? "",
            customer.address?.postalCode ?? "",
            customer.companyName ?? "",
            customer.phone ?? "",
            customer.website ?? "",
            customer.customerId ?? ""
          )

          self.webView.loadHTMLString(html, baseURL: nil)
        case let .failure(error):
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if detailItem == "Create a Charge" {
      APIClient.shared.createCharge(
        token: qa[2],
        cvv: qa[4],
        capture: qa[20] == "YES",
        currency: nil,
        amount: qa[6],
        taxAmount: qa[8],
        taxExempt: qa[22] == "YES",
        tip: qa[12],
        surchargeFeeAmount: qa[10],
        description: qa[14],
        order: nil,
        orderID: qa[16],
        poNumber: nil,
        metadata: nil,
        descriptor: qa[18],
        entryType: nil,
        idempotencyKey: nil
      ) { result in
        switch result {
        case let .success(charge):

          UserDefaults.standard.set(charge.id, forKey: "chargeId")

          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "\(charge.id ?? "")\n\(charge.statusDescription ?? "")"
          )
          html = String(format: html, qa[2])
          self.webView.loadHTMLString(html, baseURL: nil)

        case let .failure(error):
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          html = String(format: html, qa[2])
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if title == "Retrieve a Charge" {
      APIClient.shared.retrieveCharge(id: qa[2]) { result in
        switch result {
        case let .success(charge):

          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "Charge ID: \(charge.id ?? "")\nAmount: \(charge.amount ?? "")"
          )
          html = String(format: html, qa[2])
          self.webView.loadHTMLString(html, baseURL: nil)

        case let .failure(error):
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          html = String(format: html, qa[2])
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if title == "Virtual Terminal (CHARGE)" {
      activityIndicator.startAnimating()

      let billingAddress = SPAddress(
        line1: qa[14],
        line2: nil,
        city: nil,
        country: "US",
        state: nil,
        postalCode: qa[16]
      )

      APIClient.shared.tokenize(
        paymentType: .creditCard,
        accountNumber: qa[8],
        expDate: expDateFromString(qa[10]),
        cvv: qa[12],
        accountType: nil,
        routing: nil,
        pin: nil,
        billingAddress: billingAddress,
        name: qa[4]
      ) { result in
        switch result {
        case let .success(paymentMethod):

          APIClient.shared.createCharge(
            token: paymentMethod.token,
            cvv: qa[12],
            capture: qa[2] == "YES",
            currency: nil,
            amount: qa[6],
            taxAmount: qa[18],
            taxExempt: false,
            tip: nil,
            surchargeFeeAmount: nil,
            description: qa[22],
            order: nil,
            orderID: nil,
            poNumber: qa[20],
            metadata: nil,
            descriptor: nil,
            entryType: nil,
            idempotencyKey: nil
          ) { result in
            switch result {
            case let .success(charge):

              let html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: """
                <div id="info">
                Amount: $\(charge.amount ?? "")<br>
                Status: \(charge.status ?? "")<br>
                Status message: \(charge.statusDescription ?? "")<br>
                txnID #: \(charge.id ?? "")</div>
                """
              )
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()

            case let .failure(error):
              var html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: error.localizedDescription
              )
              html = String(format: html, qa[2])
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            }
          }
        case let .failure(error):
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          self.webView.loadHTMLString(html, baseURL: nil)
          self.activityIndicator.stopAnimating()
        }
      }

      return false
    } else if title == "Virtual Terminal (ACH)" {
      activityIndicator.startAnimating()

      let billingAddress = SPAddress(
        line1: qa[14],
        line2: nil,
        city: qa[16],
        country: qa[22],
        state: qa[18],
        postalCode: qa[20]
      )

      APIClient.shared.tokenize(
        paymentType: .ach,
        accountNumber: qa[10],
        expDate: nil,
        cvv: nil,
        accountType: qa[2],
        routing: qa[8],
        pin: nil,
        billingAddress: billingAddress,
        name: qa[4]
      ) { result in
        switch result {
        case let .success(paymentMethod):

          APIClient.shared.createCharge(
            token: paymentMethod.token,
            cvv: nil,
            capture: false,
            currency: qa[10],
            amount: qa[6],
            taxAmount: nil,
            taxExempt: false,
            tip: nil,
            surchargeFeeAmount: nil,
            description: qa[26],
            order: nil,
            orderID: nil,
            poNumber: nil,
            metadata: nil,
            descriptor: nil,
            entryType: nil,
            idempotencyKey: nil
          ) { result in
            switch result {
            case let .success(charge):
              let html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: """
                <div id="info">
                Amount: $\(charge.amount ?? "")<br>
                Status: \(charge.status ?? "")<br>
                Status message: \(charge.statusDescription ?? "")<br>
                txnID #: \(charge.id ?? "")</div>
                """
              )
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            case let .failure(error):
              var html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: error.localizedDescription
              )
              html = String(format: html, qa[2])
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            }
          }
        case let .failure(error):

          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          self.webView.loadHTMLString(html, baseURL: nil)
          self.activityIndicator.stopAnimating()
        }
      }

      return false
    } else if title == "Virtual Terminal (GIFT CARD)" {
      activityIndicator.startAnimating()

      APIClient.shared.tokenize(
        paymentType: .giftCard,
        accountNumber: qa[4],
        expDate: nil,
        cvv: nil,
        accountType: nil,
        routing: nil,
        pin: qa[8],
        billingAddress: nil,
        name: qa[2]
      ) { result in
        switch result {
        case let .success(paymentMethod):
          APIClient.shared.createCharge(
            token: paymentMethod.token,
            cvv: nil,
            capture: false,
            currency: qa[10],
            amount: qa[6],
            taxAmount: nil,
            taxExempt: false,
            tip: nil,
            surchargeFeeAmount: nil,
            description: nil,
            order: nil,
            orderID: nil,
            poNumber: nil,
            metadata: nil,
            descriptor: nil,
            entryType: nil,
            idempotencyKey: nil
          ) { result in
            switch result {
            case let .success(charge):
              let html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: """
                <div id="info">
                Amount: $\(charge.amount ?? "")<br>
                Status: \(charge.status ?? "")<br>
                Status message: \(charge.statusDescription ?? "")<br>
                txnID #: \(charge.id ?? "")</div>
                """
              )
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            case let .failure(error):
              var html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: error.localizedDescription
              )
              html = String(format: html, qa[2])
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            }
          }
        case let .failure(error):
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          html = String(format: html, qa[2])
          self.webView.loadHTMLString(html, baseURL: nil)
          self.activityIndicator.stopAnimating()
        }
      }

      return false
    }
    return true
  }

  @objc func pay() {
    guard let cardNumber = cardTextField.cardNumber,
          let cvc = cardTextField.cvc,
          let zip = cardTextField.postalCode else {
      return
    }

    activityIndicator.startAnimating()

    let startTime = CACurrentMediaTime()
    // perform some action

    let billingAddress = SPAddress(
      line1: nil,
      line2: nil,
      city: nil,
      country: nil,
      state: nil,
      postalCode: zip
    )

    APIClient.shared.tokenize(
      paymentType: .creditCard,
      accountNumber: cardNumber,
      expDate: .init(month: cardTextField.expirationMonth, year: cardTextField.expirationYear),
      cvv: cvc,
      accountType: nil,
      routing: nil,
      pin: nil,
      billingAddress: billingAddress,
      name: "Michael Smith"
    ) { result in
      switch result {
      case let .success(paymentMethod):

        APIClient.shared.createCharge(
          token: paymentMethod.token,
          cvv: cvc,
          capture: true,
          currency: nil,
          amount: (self.amountTextField.text?.replacingOccurrences(of: ",", with: "")) ?? "",
          taxAmount: nil,
          taxExempt: false,
          tip: nil,
          surchargeFeeAmount: nil,
          description: "",
          order: nil,
          orderID: nil,
          poNumber: nil,
          metadata: nil,
          descriptor: nil,
          entryType: nil,
          idempotencyKey: nil
        ) { result in
          self.activityIndicator.stopAnimating()

          switch result {
          case let .success(charge):
            let elapsedTime = CACurrentMediaTime() - startTime
            let success = """
                Amount: $\(charge.amount ?? "")
                Status: \(charge.status ?? "")
                Status message: \(charge.statusDescription ?? "")
                txnID #: \(charge.id ?? "")
                TimeInterval: \(elapsedTime) s
            """
            self.displayAlert(withTitle: "Success", message: success, restartDemo: true)

          case let .failure(error):
            self.displayAlert(
              withTitle: "Error creating Charge",
              message: error.localizedDescription,
              restartDemo: false
            )
          }
        }
      case let .failure(error):
        self.activityIndicator.stopAnimating()
        self.displayAlert(
          withTitle: "Error creating token",
          message: error.localizedDescription,
          restartDemo: false
        )
      }
    }
  }

  @objc func authContent() -> String {
    guard let publishableKey = UserDefaults.standard.string(forKey: "publishableKey"),
          let secretKey = UserDefaults.standard.string(forKey: "secretkey"),
          let env = Environment(rawValue: UInt(UserDefaults.standard.integer(forKey: "env"))) else {
      return .init()
    }

    return authContentHTML(
      resultMessage: nil,
      secretKey: secretKey,
      publishableKey: publishableKey,
      environment: env
    )
  }

  private func authContentHTML(
    resultMessage: String?,
    secretKey: String,
    publishableKey: String,
    environment: Environment
  ) -> String {
    assert(title == "Authentication", "Wrong place to call this function")

    guard var contentHTML else {
      return ""
    }

    if let resultMessage = resultMessage {
      contentHTML = contentHTML.replacingOccurrences(of: "<!--[RESULTS]-->", with: resultMessage)
    }

    contentHTML = String(format: contentHTML,
                         publishableKey,
                         secretKey,
                         environment == .sandbox ? "selected" : "",
                         environment == .production ? "selected" : "",
                         environment == .staging ? "selected" : "",
                         environment == .qat ? "selected" : "")

    return contentHTML
  }
}
