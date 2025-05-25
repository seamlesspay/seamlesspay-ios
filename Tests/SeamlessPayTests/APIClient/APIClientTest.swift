// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class APIClientTest: XCTestCase {
  private var client: APIClient!
    
  override func setUp() {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [APIClientURLProtocolMock.self]
    let session = URLSession(configuration: configuration)
        
    client = APIClient(
      config: .init(environment: .production, secretKey: "sk_TEST", proxyAccountId: .none),
      session: session
    )
        
    APIClientURLProtocolMock.testingRequest = nil
    // Response type doesn't matter
    APIClientURLProtocolMock.setFailureResponse()
  }
    
  // MARK: - Tests
  // MARK: Tokenize
  func testTokenizeCreditCardRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
    // when
    client.tokenize(
      paymentType: .creditCard,
      accountNumber: "test_accountNumber",
      expDate: .init(month: 7, year: 33),
      cvv: "test_cvv",
      accountType: "test_accountType",
      routing: "test_routing",
      pin: "test_ping",
      billingAddress: makeTestAddress(),
      name: "test_name"
    ) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://pan-vault.seamlesspay.com/tokens")
      XCTAssertEqual(method, "POST")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      let cvv = body["cvv"] as! String
      let accountNumber = body["accountNumber"] as! String
      let billingAddress = body["billingAddress"] as! [String: String]
      let expDate = body["expDate"] as! String
      let name = body["name"] as! String
      let paymentType = body["paymentType"] as! String
            
      // parameters
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertEqual(cvv, "test_cvv")
            
      XCTAssertEqual(accountNumber, "test_accountNumber")
      XCTAssertEqual(expDate, "7/33")
      XCTAssertEqual(name, "test_name")
      XCTAssertEqual(paymentType, "credit_card")
            
      XCTAssertNil(body["bankAccountType"])
      XCTAssertNil(body["routingNumber"])
      XCTAssertNil(body["pinNumber"])
            
      // billing address
      let postalCode = billingAddress["postalCode"]!
      let country = billingAddress["country"]!
      let city = billingAddress["city"]!
      let line1 = billingAddress["line1"]!
      let line2 = billingAddress["line2"]!
      let state = billingAddress["state"]!
            
      XCTAssertEqual(postalCode, "test_postalCode")
      XCTAssertEqual(country, "test_country")
      XCTAssertEqual(city, "test_city")
      XCTAssertEqual(line1, "test_line1")
      XCTAssertEqual(line2, "test_line2")
      XCTAssertEqual(state, "test_state")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testTokenizeGiftCardRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.tokenize(
      paymentType: .giftCard,
      accountNumber: "test_accountNumber",
      expDate: .init(month: 7, year: 33),
      cvv: "test_cvv",
      accountType: "test_accountType",
      routing: "test_routing",
      pin: "test_ping",
      billingAddress: makeTestAddress(),
      name: "test_name"
    ) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      let pinNumber = body["pinNumber"] as! String
            
      // parameters
      XCTAssertEqual(pinNumber, "test_ping")
            
      XCTAssertNil(body["cvv"])
      XCTAssertNil(body["expDate"])
      XCTAssertNil(body["bankAccountType"])
      XCTAssertNil(body["routingNumber"])
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testTokenizeAchRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.tokenize(
      paymentType: .ach,
      accountNumber: "test_accountNumber",
      expDate: .init(month: 7, year: 33),
      cvv: "test_cvv",
      accountType: "test_accountType",
      routing: "test_routing",
      pin: "test_ping",
      billingAddress: makeTestAddress(),
      name: "test_name"
    ) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      let bankAccountType = body["bankAccountType"] as! String
      let routing = body["routingNumber"] as! String
            
      // parameters
      XCTAssertEqual(bankAccountType, "test_accountType")
      XCTAssertEqual(routing, "test_routing")
            
      XCTAssertNil(body["cvv"])
      XCTAssertNil(body["expDate"])
      XCTAssertNil(body["pinNumber"])
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  // MARK: Digital Wallet Tests
  func testTokenizeDigitalWalletRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    let digitalWallet = DigitalWallet(
      merchantId: "test_merchant_id",
      token: .init(
        paymentData: .init(
          data: "test_payment_data",
          signature: "test_signature",
          header: .init(
            publicKeyHash: "test_public_key_hash",
            ephemeralPublicKey: "test_ephemeral_public_key",
            transactionId: "test_transaction_id"
          ),
          version: "EC_v1"
        ),
        paymentMethod: .init(
          displayName: "Visa •••• 1234",
          network: "Visa",
          type: "credit"
        ),
        transactionIdentifier: "test_transaction_identifier"
      )
    )
        
    client.tokenize(digitalWallet: digitalWallet) { result in
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://pan-vault.seamlesspay.com/tokens")
      XCTAssertEqual(method, "POST")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      let paymentType = body["paymentType"] as! String
      XCTAssertEqual(paymentType, "credit_card")
      XCTAssertNotNil(body["digitalWallet"])
            
      let digitalWalletData = body["digitalWallet"] as! [String: Any]
      XCTAssertEqual(digitalWalletData["merchantId"] as! String, "test_merchant_id")
      XCTAssertEqual(digitalWalletData["type"] as! String, "apple_pay")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  // MARK: Customer Tests
  func testCreateCustomerRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.createCustomer(
      name: "John Doe",
      email: "john@example.com",
      address: makeTestAddress(),
      companyName: "Test Company",
      notes: "Test notes",
      phone: "555-1234",
      website: "https://example.com",
      paymentMethods: [makeTestPaymentMethod()],
      metadata: "test_metadata"
    ) { result in
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://api.seamlesspay.com/customers")
      XCTAssertEqual(method, "POST")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      // parameters
      XCTAssertEqual(body["name"] as! String, "John Doe")
      XCTAssertEqual(body["email"] as! String, "john@example.com")
      XCTAssertEqual(body["companyName"] as! String, "Test Company")
      XCTAssertEqual(body["description"] as! String, "Test notes")
      XCTAssertEqual(body["phone"] as! String, "555-1234")
      XCTAssertEqual(body["website"] as! String, "https://example.com")
      XCTAssertEqual(body["metadata"] as! String, "test_metadata")
            
      let address = body["address"] as! [String: String]
      XCTAssertEqual(address["line1"], "test_line1")
      XCTAssertEqual(address["city"], "test_city")
            
      let paymentMethods = body["paymentMethods"] as! [String]
      XCTAssertEqual(paymentMethods.first, "test_token")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testUpdateCustomerRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.updateCustomer(
      id: "customer_123",
      name: "Jane Doe",
      email: "jane@example.com",
      address: makeTestAddress(),
      companyName: "Updated Company",
      notes: "Updated notes",
      phone: "555-5678",
      website: "https://updated.com",
      paymentMethods: [makeTestPaymentMethod()],
      metadata: "updated_metadata"
    ) { result in
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://api.seamlesspay.com/customers/customer_123")
      XCTAssertEqual(method, "PUT")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testRetrieveCustomerRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.retrieveCustomer(id: "customer_123") { result in
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges/customer_123")
      XCTAssertEqual(method, "GET")
            
      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  // MARK: Charge
  func testListChargesRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.listCharges { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges")
      XCTAssertEqual(method, "GET")
            
      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testGetChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.retrieveCharge(id: "test_charge_id") { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges/test_charge_id")
      XCTAssertEqual(method, "GET")
            
      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testVoidChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.voidCharge(id: "test_charge_id") { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertNil(request.httpBodyStream)
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges/test_charge_id")
      XCTAssertEqual(method, "DELETE")
            
      // headers
      XCTAssertNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testCreateChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.createCharge(
      token: "test_token",
      amount: 100,
      cvv: "test_cvv",
      capture: true,
      currency: "test_currency",
      taxAmount: 1,
      taxExempt: false,
      tip: 3,
      surchargeFeeAmount: 12,
      description: "test_description",
      order: ["test_order_key": "test_order_value"],
      orderID: "test_orderID",
      poNumber: "test_poNumber",
      metadata: "test_metadata",
      descriptor: "test_descriptor",
      entryType: "test_entryType",
      idempotencyKey: "test_idempotencyKey"
    ) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges")
      XCTAssertEqual(method, "POST")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      let token = body["token"] as! String
      let capture = body["capture"] as! Bool
      let cvv = body["cvv"] as! String
      let currency = body["currency"] as! String
      let taxAmount = body["taxAmount"] as! Int
      let taxExempt = body["taxExempt"] as! Bool
      let tip = body["tip"] as! Int
      let surchargeFeeAmount = body["surchargeFeeAmount"] as! Int
      let description = body["description"] as! String
      let order = body["order"] as! [String: String]
            
      let orderId = body["orderID"] as! String
      let poNumber = body["poNumber"] as! String
      let metadata = body["metadata"] as! String
      let descriptor = body["descriptor"] as! String
      let entryType = body["entryType"] as! String
      let idempotencyKey = body["idempotencyKey"] as! String
            
      // parameters
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(capture, true)
      XCTAssertEqual(cvv, "test_cvv")
      XCTAssertEqual(currency, "test_currency")
      XCTAssertEqual(taxAmount, 1)
      XCTAssertEqual(taxExempt, false)
      XCTAssertEqual(tip, 3)
      XCTAssertEqual(surchargeFeeAmount, 12)
      XCTAssertEqual(description, "test_description")
      XCTAssertEqual(order, ["test_order_key": "test_order_value"])
      XCTAssertEqual(orderId, "test_orderID")
      XCTAssertEqual(poNumber, "test_poNumber")
      XCTAssertEqual(metadata, "test_metadata")
      XCTAssertEqual(descriptor, "test_descriptor")
      XCTAssertEqual(entryType, "test_entryType")
      XCTAssertEqual(idempotencyKey, "test_idempotencyKey")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  // MARK: Refund
  func testCreateRefundRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.createRefund(
      token: "test_token",
      amount: 101
    ) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://api.seamlesspay.com/refunds")
      XCTAssertEqual(method, "POST")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      let token = body["token"] as! String
      let amount = body["amount"] as! Int
            
      // parameters
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(amount, 101)
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testCreateRefundWithAllParametersRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    // when
    client.createRefund(
      token: "test_token",
      amount: 101,
      currency: "USD",
      descriptor: "test_descriptor",
      idempotencyKey: "test_idempotency",
      metadata: "test_metadata"
    ) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      let token = body["token"] as! String
      let amount = body["amount"] as! Int
      let currency = body["currency"] as! String
      let descriptor = body["descriptor"] as! String
      let idempotencyKey = body["idempotencyKey"] as! String
      let metadata = body["metadata"] as! String
            
      // parameters
      XCTAssertEqual(token, "test_token")
      XCTAssertEqual(amount, 101)
      XCTAssertEqual(currency, "USD")
      XCTAssertEqual(descriptor, "test_descriptor")
      XCTAssertEqual(idempotencyKey, "test_idempotency")
      XCTAssertEqual(metadata, "test_metadata")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testCreateChargeWithRequest() {
    let expectation = expectation(description: "CreateChargeSuccess")
        
    let token = "testToken"
    let cvv = "999testCVC"
    let request = ChargeRequest(
      amount: 100,
      capture: true,
      currency: "USD",
      description: "Test charge",
      descriptor: "descriptor",
      entryType: "entryType",
      idempotencyKey: "idempotencyKey",
      metadata: "metadata",
      order: ["order123": "order123Value"],
      orderID: "orderID123",
      poNumber: "po123",
      surchargeFeeAmount: 2,
      taxAmount: 10,
      taxExempt: false,
      tip: 5
    )
        
    client.createCharge(token: token, cvv: cvv, request: request) { result in
            
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
            
      XCTAssertEqual(url, "https://api.seamlesspay.com/charges")
      XCTAssertEqual(method, "POST")
            
      // headers
      XCTAssertNotNil(headers["Content-Length"])
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
            
      let token = body["token"] as! String
      let capture = body["capture"] as! Bool
      let cvv = body["cvv"] as! String
      let currency = body["currency"] as! String
      let taxAmount = body["taxAmount"] as! Int
      let taxExempt = body["taxExempt"] as! Bool
      let tip = body["tip"] as! Int
      let surchargeFeeAmount = body["surchargeFeeAmount"] as! Int
      let description = body["description"] as! String
      let order = body["order"] as! [String: String]
            
      let orderId = body["orderID"] as! String
      let poNumber = body["poNumber"] as! String
      let metadata = body["metadata"] as! String
      let descriptor = body["descriptor"] as! String
      let entryType = body["entryType"] as! String
      let idempotencyKey = body["idempotencyKey"] as! String
            
      // parameters
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertEqual(token, "testToken")
      XCTAssertEqual(capture, true)
      XCTAssertEqual(cvv, "999testCVC")
      XCTAssertEqual(currency, "USD")
      XCTAssertEqual(taxAmount, 10)
      XCTAssertEqual(taxExempt, false)
      XCTAssertEqual(tip, 5)
      XCTAssertEqual(surchargeFeeAmount, 2)
      XCTAssertEqual(description, "Test charge")
      XCTAssertEqual(order, ["order123": "order123Value"])
      XCTAssertEqual(orderId, "orderID123")
      XCTAssertEqual(poNumber, "po123")
      XCTAssertEqual(metadata, "metadata")
      XCTAssertEqual(descriptor, "descriptor")
      XCTAssertEqual(entryType, "entryType")
      XCTAssertEqual(idempotencyKey, "idempotencyKey")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  // MARK: Edge Cases
  func testTokenizeWithMinimalParameters() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.tokenize(
      paymentType: .creditCard,
      accountNumber: "4111111111111111"
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      XCTAssertEqual(body["accountNumber"] as! String, "4111111111111111")
      XCTAssertEqual(body["paymentType"] as! String, "credit_card")
      XCTAssertNil(body["cvv"])
      XCTAssertNil(body["expDate"])
      XCTAssertNil(body["billingAddress"])
      XCTAssertNil(body["name"])
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testCreateChargeWithMinimalParameters() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.createCharge(
      token: "test_token",
      amount: 100
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      XCTAssertEqual(body["token"] as! String, "test_token")
      XCTAssertEqual(body["amount"] as! Int, 100)
      XCTAssertNil(body["cvv"])
      XCTAssertNil(body["currency"])
      XCTAssertNil(body["description"])
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  // MARK: Validation Tests
  func testDeviceFingerprintIncludedInTokenize() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.tokenize(
      paymentType: .creditCard,
      accountNumber: "4111111111111111"
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertTrue(!(body["deviceFingerprint"] as! String).isEmpty)
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testDeviceFingerprintIncludedInCreateCharge() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.createCharge(
      token: "test_token",
      amount: 100
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      XCTAssertNotNil(body["deviceFingerprint"])
      XCTAssertTrue(!(body["deviceFingerprint"] as! String).isEmpty)
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testRequiredFieldsInTokenizeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.tokenize(
      paymentType: .creditCard,
      accountNumber: "4111111111111111"
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      // Required fields should always be present
      XCTAssertNotNil(body["paymentType"])
      XCTAssertNotNil(body["accountNumber"])
      XCTAssertNotNil(body["deviceFingerprint"])
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testRequiredFieldsInCreateChargeRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.createCharge(
      token: "test_token",
      amount: 100
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      // Required fields should always be present
      XCTAssertNotNil(body["token"])
      XCTAssertNotNil(body["amount"])
      XCTAssertNotNil(body["deviceFingerprint"])
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testRequiredFieldsInCreateCustomerRequest() {
    let expectation = XCTestExpectation(description: "Request completed")
        
    client.createCustomer(
      name: "John Doe",
      email: "john@example.com"
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      // Required fields should always be present
      XCTAssertNotNil(body["name"])
      XCTAssertNotNil(body["email"])
      XCTAssertEqual(body["name"] as! String, "John Doe")
      XCTAssertEqual(body["email"] as! String, "john@example.com")
            
      expectation.fulfill()
    }
        
    wait(for: [expectation], timeout: 1.5)
  }
    
  func testRequiredFieldsInCreateRefundRequest() {
    let expectation = XCTestExpectation(description: "Request completed")

    client.createRefund(
      token: "test_token",
      amount: 100
    ) { result in
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
            
      // Required fields should always be present
      XCTAssertNotNil(body["token"])
      XCTAssertNotNil(body["amount"])
      XCTAssertEqual(body["token"] as! String, "test_token")
      XCTAssertEqual(body["amount"] as! Int, 100)
            
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.5)
  }
        
  func testCreateChargeWithRequest_captureNil() {
    let expectation = XCTestExpectation(description: "CreateChargeWithCaptureNil")
            
    let token = "testToken"
    let cvv = "999testCVC"
    let request = ChargeRequest(
      amount: 100,
      capture: nil,
      currency: "USD",
      description: "Test charge",
      descriptor: "descriptor",
      entryType: "entryType",
      idempotencyKey: "idempotencyKey",
      metadata: "metadata",
      order: ["order123": "order123Value"],
      orderID: "orderID123",
      poNumber: "po123",
      surchargeFeeAmount: 2,
      taxAmount: 10,
      taxExempt: false,
      tip: 5
    )
            
    client.createCharge(token: token, cvv: cvv, request: request) { result in
      // then
      let request = APIClientURLProtocolMock.testingRequest!
      let body = request.bodyStreamAsJSON()!
      XCTAssertNil(
        body["capture"],
        "'capture' key should not be present when capture is nil"
      )
      expectation.fulfill()
    }
            
    wait(for: [expectation], timeout: 1.5)
  }
        
  // MARK: SDK Data
  func testRetrieveSDKDataWithoutProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")
            
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [APIClientURLProtocolMock.self]
    let session = URLSession(configuration: configuration)
            
    let client = APIClient(
      config: .init(
        environment: .production,
        secretKey: "sk_TEST",
        proxyAccountId: .none
      ),
      session: session
    )
            
    client.retrieveSDKData { result in
                
      // then
      let request = APIClientURLProtocolMock.testingRequest!
                
      let headers = request.allHTTPHeaderFields!
      let url = request.url!.absoluteString
      let method = request.httpMethod!
                
      XCTAssertEqual(url, "https://api.seamlesspay.com/sdk-data")
      XCTAssertEqual(method, "GET")
                
      // headers
      XCTAssertEqual(headers["Content-Type"], "application/json")
      XCTAssertEqual(headers["Accept"], "application/json")
      XCTAssertEqual(headers["API-Version"], "v2")
      XCTAssertEqual(headers["User-Agent"], "seamlesspay_ios")
      XCTAssertEqual(headers["Authorization"], "Bearer sk_TEST")
      XCTAssertNil(headers["SeamlessPay-Account"])
                
      expectation.fulfill()
    }
            
    wait(for: [expectation], timeout: 1.5)
  }
        
  func testRetrieveSDKDataWithProxyAccountId() {
    let expectation = XCTestExpectation(description: "Request completed")
            
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [APIClientURLProtocolMock.self]
    let session = URLSession(configuration: configuration)
            
    let client = APIClient(
      config: .init(
        environment: .production,
        secretKey: "sk_TEST",
        proxyAccountId: "proxyAccountId_TEST"
      ),
      session: session
    )
            
    client.retrieveSDKData { result in
                
      // then
      let request = APIClientURLProtocolMock.testingRequest!
                
      let headers = request.allHTTPHeaderFields!
                
      // headers
      XCTAssertEqual(headers["SeamlessPay-Account"], "proxyAccountId_TEST")
                
      expectation.fulfill()
    }
            
    wait(for: [expectation], timeout: 1.5)
  }
}

// MARK: - Test Data Factories
private extension APIClientTest {
  func makeTestAddress() -> Address {
    Address(
      line1: "test_line1",
      line2: "test_line2",
      country: "test_country",
      state: "test_state",
      city: "test_city",
      postalCode: "test_postalCode"
    )
  }
  
  func makeTestPaymentMethod() -> PaymentMethod {
    return .init(
      token: "test_token",
      expDate: "12/25",
      lastFour: "1234",
      name: "John Doe",
      paymentNetwork: .visa,
      paymentType: .creditCard,
      bankAccountType: "Checking",
      routingNumber: "1234567890",
      verificationResults: nil,
      billingAddress: makeTestAddress()
    )
  }
}
