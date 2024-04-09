// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit
import SeamlessPay

private var apiClient: APIClient = .init(
  authorization: mockSPAuthorization
)

extension DetailViewController {
  @objc func configureSingleLineCardFormView() {
    singleLineCardFormView = SingleLineCardForm(authorization: sharedSPAuthorization)
    singleLineCardFormView.countryCode = "US"
  }

  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable function_body_length
  @objc func shouldStartDecidePolicy(_ request: URLRequest) -> Bool {
    guard
      let absoluteString = request.url?.absoluteString.removingPercentEncoding else {
      return true
    }

    let str = absoluteString
      .replacingOccurrences(of: "=", with: "&")
      .replacingOccurrences(of: "?", with: "&")
      .replacingOccurrences(of: "+", with: " ")

    let params = str.components(separatedBy: "&")

    if params.count == 1 {
      return true
    }

    if detailItem == "Authentication" {
      let secretKey = params[2]
      let envSting = params[4]
      let env = environmentFromString(envSting)

      let updateWebView: (String, Bool) -> Void = { message, success in
        let html = self.authContentHTML(
          resultMessage: message,
          secretKey: secretKey,
          environment: env
        )
        self.webView.loadHTMLString(html, baseURL: nil)

        if success {
          sharedSPAuthorization = .init(
            environment: env,
            secretKey: secretKey
          )

          apiClient = .init(
            authorization: sharedSPAuthorization
          )
        }
      }

      apiClient.listCharges { result in
        switch result {
        case .success:
          updateWebView("Authentication success!", true)
        case let .failure(error):
          updateWebView(error.localizedDescription, false)
        }
      }

      return false
    } else if ["Add Credit/Debit Card", "Add Gift Card", "Add ACH"].contains(detailItem) {
      let billingAddress = Address(
        line1: params[14],
        line2: params[16],
        country: params[20],
        state: params[22],
        city: params[18],
        postalCode: params[24]
      )

      apiClient.tokenize(
        paymentType: paymentTypeFromString(params[2]),
        accountNumber: params[4],
        expDate: expDateFromString(params[6]),
        cvv: params[8],
        accountType: params[10],
        routing: params[8],
        pin: params[12],
        billingAddress: billingAddress,
        name: params[26]
      ) { result in
        switch result {
        case let .success(paymentMethod):

          UserDefaults.standard.set(try? paymentMethod.encode(), forKey: "paymentMethod")

          let paymentMethodInfo = """
          Token info:<br>\(paymentMethod.token)<br>\
          \(paymentMethod.paymentType?.rawValue ?? "")<br>\
          \(paymentMethod.lastFour ?? "")<br>\
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
      var paymentMethods: [PaymentMethod] = []
      if let savedPaymentMethodData = UserDefaults.standard.data(forKey: "paymentMethod"),
         let paymentMethod = try? PaymentMethod.decode(savedPaymentMethodData) {
        paymentMethods.append(paymentMethod)
      }

      let address = Address(
        line1: params[6],
        line2: params[8],
        country: params[12],
        state: params[14],
        city: params[10],
        postalCode: params[16]
      )

      apiClient.createCustomer(
        name: params[2],
        email: params[4],
        address: address,
        companyName: params[18],
        notes: nil,
        phone: params[20],
        website: params[22],
        paymentMethods: paymentMethods,
        metadata: "{\"customOption\":\"example\"}"
      ) { result in
        switch result {
        case let .success(customer):
          UserDefaults.standard.set(try? customer.encode(), forKey: "customer")
          let html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: customer.id
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
      apiClient.retrieveCustomer(id: params[2]) { result in
        switch result {
        case let .success(customer):
          UserDefaults.standard.set(try? customer.encode(), forKey: "customer")
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "Customer Name: \(customer.name ?? "")"
          )
          html = String(format: html, customer.id)
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
      let address = Address(
        line1: params[6],
        line2: params[8],
        country: params[12],
        state: params[14],
        city: params[10],
        postalCode: params[16]
      )

      apiClient.updateCustomer(
        id: params[24],
        name: params[2],
        email: params[4],
        address: address,
        companyName: params[18],
        notes: nil,
        phone: params[20],
        website: params[22],
        paymentMethods: nil,
        metadata: "{\"customOption\":\"exampleupdate\"}"
      ) { result in
        switch result {
        case let .success(customer):
          let data = try? customer.encode()
          UserDefaults.standard.set(data, forKey: "customer")

          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "Updated success!"
          )
          html = String(
            format: html,
            customer.name ?? "",
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
            customer.id
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
      apiClient.createCharge(
        token: params[2],
        cvv: params[4],
        capture: params[20] == "YES",
        currency: nil,
        amount: params[6],
        taxAmount: params[8],
        taxExempt: params[22] == "YES",
        tip: params[12],
        surchargeFeeAmount: params[10],
        description: params[14],
        order: nil,
        orderID: params[16],
        poNumber: nil,
        metadata: nil,
        descriptor: params[18],
        entryType: nil,
        idempotencyKey: nil
      ) { result in
        switch result {
        case let .success(charge):

          UserDefaults.standard.set(charge.id, forKey: "chargeId")

          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "\(charge.id)\n\(charge.statusDescription ?? "")"
          )
          html = String(format: html, params[2])
          self.webView.loadHTMLString(html, baseURL: nil)

        case let .failure(error):
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          html = String(format: html, params[2])
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if title == "Retrieve a Charge" {
      apiClient.retrieveCharge(id: params[2]) { result in
        switch result {
        case let .success(charge):

          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: "Charge ID: \(charge.id)\nAmount: \(charge.amount ?? "")"
          )
          html = String(format: html, params[2])
          self.webView.loadHTMLString(html, baseURL: nil)

        case let .failure(error):
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          html = String(format: html, params[2])
          self.webView.loadHTMLString(html, baseURL: nil)
        }
      }

      return false
    } else if title == "Virtual Terminal (CHARGE)" {
      activityIndicator.startAnimating()

      let billingAddress = Address(
        line1: params[14],
        line2: nil,
        country: "US",
        state: nil,
        city: nil,
        postalCode: params[16]
      )

      apiClient.tokenize(
        paymentType: .creditCard,
        accountNumber: params[8],
        expDate: expDateFromString(params[10]),
        cvv: params[12],
        accountType: nil,
        routing: nil,
        pin: nil,
        billingAddress: billingAddress,
        name: params[4]
      ) { result in
        switch result {
        case let .success(paymentMethod):

          apiClient.createCharge(
            token: paymentMethod.token,
            cvv: params[12],
            capture: params[2] == "YES",
            currency: nil,
            amount: params[6],
            taxAmount: params[18],
            taxExempt: false,
            tip: nil,
            surchargeFeeAmount: nil,
            description: params[22],
            order: nil,
            orderID: nil,
            poNumber: params[20],
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
                Status: \(charge.status?.rawValue ?? "")<br>
                Status message: \(charge.statusDescription ?? "")<br>
                txnID #: \(charge.id)</div>
                """
              )
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()

            case let .failure(error):
              var html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: error.localizedDescription
              )
              html = String(format: html, params[2])
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

      let billingAddress = Address(
        line1: params[14],
        line2: nil,
        country: params[22],
        state: params[18],
        city: params[16],
        postalCode: params[20]
      )

      apiClient.tokenize(
        paymentType: .ach,
        accountNumber: params[10],
        expDate: nil,
        cvv: nil,
        accountType: params[2],
        routing: params[8],
        pin: nil,
        billingAddress: billingAddress,
        name: params[4]
      ) { result in
        switch result {
        case let .success(paymentMethod):

          apiClient.createCharge(
            token: paymentMethod.token,
            cvv: nil,
            capture: false,
            currency: params[10],
            amount: params[6],
            taxAmount: nil,
            taxExempt: false,
            tip: nil,
            surchargeFeeAmount: nil,
            description: params[26],
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
                Status: \(charge.status?.rawValue ?? "")<br>
                Status message: \(charge.statusDescription ?? "")<br>
                txnID #: \(charge.id)</div>
                """
              )
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            case let .failure(error):
              var html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: error.localizedDescription
              )
              html = String(format: html, params[2])
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

      apiClient.tokenize(
        paymentType: .giftCard,
        accountNumber: params[4],
        expDate: nil,
        cvv: nil,
        accountType: nil,
        routing: nil,
        pin: params[8],
        billingAddress: nil,
        name: params[2]
      ) { result in
        switch result {
        case let .success(paymentMethod):
          apiClient.createCharge(
            token: paymentMethod.token,
            cvv: nil,
            capture: false,
            currency: params[10],
            amount: params[6],
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
                Status: \(charge.status?.rawValue ?? "")<br>
                Status message: \(charge.statusDescription ?? "")<br>
                txnID #: \(charge.id)</div>
                """
              )
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            case let .failure(error):
              var html = self.contentHTML.replacingOccurrences(
                of: "<!--[RESULTS]-->",
                with: error.localizedDescription
              )
              html = String(format: html, params[2])
              self.webView.loadHTMLString(html, baseURL: nil)
              self.activityIndicator.stopAnimating()
            }
          }
        case let .failure(error):
          var html = self.contentHTML.replacingOccurrences(
            of: "<!--[RESULTS]-->",
            with: error.localizedDescription
          )
          html = String(format: html, params[2])
          self.webView.loadHTMLString(html, baseURL: nil)
          self.activityIndicator.stopAnimating()
        }
      }

      return false
    }
    return true
  }

  // swiftlint:enable cyclomatic_complexity
  // swiftlint:enable function_body_length

  @objc func pay() {
    activityIndicator.startAnimating()

    let startTime = CACurrentMediaTime()

    let amount = (amountTextField.text?.replacingOccurrences(of: ",", with: "")) ?? ""
    singleLineCardFormView.submit(.init(amount: amount)) { result in
      self.activityIndicator.stopAnimating()

      switch result {
      case let .success(paymentResponse):
        let elapsedTime = CACurrentMediaTime() - startTime
        let success = """
            Amount: $\(paymentResponse.details.amount ?? "")
            Status: \(paymentResponse.details.status?.rawValue ?? "")
            Status message: \(paymentResponse.details.statusDescription ?? "")
            txnID #: \(paymentResponse.id)
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
  }

  @objc func authContent() -> String {
    return authContentHTML(
      resultMessage: nil,
      secretKey: sharedSPAuthorization.secretKey,
      environment: sharedSPAuthorization.environment
    )
  }

  private func authContentHTML(
    resultMessage: String?,
    secretKey: String,
    environment: Environment
  ) -> String {
    assert(title == "Authentication", "Wrong place to call this function")

    guard var contentHTML else {
      return ""
    }

    if let resultMessage {
      contentHTML = contentHTML.replacingOccurrences(of: "<!--[RESULTS]-->", with: resultMessage)
    }

    contentHTML = String(format: contentHTML,
                         secretKey,
                         environment == .sandbox ? "selected" : "",
                         environment == .production ? "selected" : "",
                         environment == .staging ? "selected" : "",
                         environment == .qat ? "selected" : "")

    return contentHTML
  }
}

extension DetailViewController {
  private var savedPaymentMethod: PaymentMethod? {
    UserDefaults.standard.data(forKey: "paymentMethod").flatMap { try? PaymentMethod.decode($0) }
  }

  private var savedCustomer: Customer? {
    UserDefaults.standard.data(forKey: "customer").flatMap { try? Customer.decode($0) }
  }

  @objc var savedPaymentMethodToken: String? {
    savedPaymentMethod?.token
  }

  @objc var savedCustomerData: [String: String] {
    [
      "name": savedCustomer?.name ?? "",
      "email": savedCustomer?.email ?? "",
      "line1": savedCustomer?.address?.line1 ?? "",
      "line2": savedCustomer?.address?.line2 ?? "",
      "city": savedCustomer?.address?.city ?? "",
      "country": savedCustomer?.address?.country ?? "",
      "state": savedCustomer?.address?.state ?? "",
      "postalCode": savedCustomer?.address?.postalCode ?? "",
      "companyName": savedCustomer?.companyName ?? "",
      "phone": savedCustomer?.phone ?? "",
      "website": savedCustomer?.website ?? "",
      "id": savedCustomer?.id ?? "",
    ]
  }
}

private extension DetailViewController {
  private func expDateFromString(_ string: String) -> ExpirationDate {
    let expElements = string
      .components(separatedBy: "/")
      .map { UInt($0) }
      .compactMap { $0 }

    guard expElements.count >= 2 else {
      return .init(month: 0, year: 0)
    }
    return .init(month: expElements[0], year: expElements[1])
  }

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
    PaymentType(rawValue: string) ?? .creditCard
  }
}
