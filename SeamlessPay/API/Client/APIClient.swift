// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public class APIClient {
  public static let shared = APIClient()

  // MARK: Private Constants
  private let apiVersion = "v2020"
  private let session: URLSession

  // MARK: Private
  private var secretKey: String?
  private var subMerchantAccountId: String?
  private var deviceFingerprint: String? {
    DeviceFingerprint.make(
      appOpenTime: appOpenTime,
      apiVersion: apiVersion
    )
  }

  private var appOpenTime: Date?
  private var sentryClient: SPSentryClient?

  // MARK: Init
  // TODO: Move under SPI
  init(session: URLSession = URLSession(configuration: .default)) {
    self.session = session
  }

  // MARK: - Public Interface
  public private(set) var publishableKey: String?
  public private(set) var environment: Environment = .sandbox

  public func set(
    secretKey: String? = nil,
    publishableKey: String,
    environment: Environment
  ) {
    self.secretKey = secretKey ?? publishableKey
    self.publishableKey = publishableKey
    self.environment = environment

    setSentryClient()
    appOpenTime = Date()
  }

  public func setSubMerchantAccountId(_ id: String) {
    subMerchantAccountId = id
  }

  // MARK: Tokenize
  public func tokenize(
    paymentType: PaymentType,
    accountNumber: String,
    expDate: ExpirationDate? = nil,
    cvv: String? = nil,
    accountType: String? = nil,
    routing: String? = nil,
    pin: String? = nil,
    billingAddress: Address? = nil,
    name: String? = nil,
    completion: ((Result<PaymentMethod, SeamlessPayError>) -> Void)?
  ) {
    var parameters: [String: Any?] = [
      "paymentType": paymentType.rawValue,
      "accountNumber": accountNumber,
      "billingAddress": billingAddress?.asParameter(),
      "name": name,
      "deviceFingerprint": deviceFingerprint,
    ]

    switch paymentType {
    case .ach:
      parameters["bankAccountType"] = accountType
      parameters["routingNumber"] = routing
    case .creditCard:
      parameters["expDate"] = expDate?.stringValue
      parameters["cvv"] = cvv
    case .giftCard:
      parameters["pinNumber"] = pin
    }

    execute(
      operation: .createToken,
      parameters: parameters,
      map: { data in
        data.flatMap { try? PaymentMethod.decode($0) }
      },
      completion: completion
    )
  }

  // MARK: Customer
  public func createCustomer(
    name: String,
    email: String,
    address: Address? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [PaymentMethod]? = nil,
    metadata: String? = nil,
    completion: ((Result<Customer, SeamlessPayError>) -> Void)?
  ) {
    customer(
      name: name,
      email: email,
      address: address,
      companyName: companyName,
      notes: notes,
      phone: phone,
      website: website,
      paymentMethods: paymentMethods,
      metadata: metadata,
      operation: .createCustomer,
      completion: completion
    )
  }

  public func updateCustomer(
    id: String,
    name: String,
    email: String,
    address: Address? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [PaymentMethod]? = nil,
    metadata: String? = nil,
    completion: ((Result<Customer, SeamlessPayError>) -> Void)?
  ) {
    customer(
      name: name,
      email: email,
      address: address,
      companyName: companyName,
      notes: notes,
      phone: phone,
      website: website,
      paymentMethods: paymentMethods,
      metadata: metadata,
      operation: .updateCustomer(id: id),
      completion: completion
    )
  }

  public func retrieveCustomer(
    id: String,
    completion: ((Result<Customer, SeamlessPayError>) -> Void)?
  ) {
    customer(operation: .retrieveCharge(id: id), completion: completion)
  }

  // MARK: Charge
  public func createCharge(
    token: String,
    cvv: String? = nil,
    capture: Bool,
    currency: String? = nil,
    amount: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderID: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    completion: ((Result<Charge, SeamlessPayError>) -> Void)?
  ) {
    charge(
      token: token,
      cvv: cvv,
      capture: capture,
      currency: currency,
      amount: amount,
      taxAmount: taxAmount,
      taxExempt: taxExempt,
      tip: tip,
      surchargeFeeAmount: surchargeFeeAmount,
      description: description,
      order: order,
      orderID: orderID,
      poNumber: poNumber,
      metadata: metadata,
      descriptor: descriptor,
      entryType: entryType,
      idempotencyKey: idempotencyKey,
      operation: .createCharge,
      completion: completion
    )
  }

  public func retrieveCharge(
    id: String,
    completion: ((Result<Charge, SeamlessPayError>) -> Void)?
  ) {
    charge(operation: .retrieveCharge(id: id), completion: completion)
  }

  public func listCharges(
    completion: ((Result<ChargePage, SeamlessPayError>) -> Void)?
  ) {
    execute(
      operation: .listCharges,
      parameters: nil,
      map: { data in
        data.flatMap { try? ChargePage.decode($0) }
      },
      completion: completion
    )
  }

  public func voidCharge(
    id: String,
    completion: ((Result<Charge, SeamlessPayError>) -> Void)?
  ) {
    execute(
      operation: .voidCharge(id: id),
      parameters: nil,
      map: { data in
        data.flatMap {
          try? Charge.decode($0)
        }
      },
      completion: completion
    )
  }

  // MARK: Verify
  public func verify(
    token: String,
    cvv: String? = nil,
    currency: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderID: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    completion: ((Result<Charge, SeamlessPayError>) -> Void)?
  ) {
    charge(
      token: token,
      cvv: cvv,
      capture: false,
      currency: currency,
      amount: nil,
      taxAmount: taxAmount,
      taxExempt: taxExempt,
      tip: tip,
      surchargeFeeAmount: surchargeFeeAmount,
      description: description,
      order: order,
      orderID: orderID,
      poNumber: poNumber,
      metadata: metadata,
      descriptor: descriptor,
      entryType: entryType,
      idempotencyKey: idempotencyKey,
      operation: .createCharge,
      completion: completion
    )
  }

  // MARK: Refunds
  public func createRefund(
    token: String,
    amount: String,
    currency: String? = nil,
    descriptor: String? = nil,
    idempotencyKey: String? = nil,
    metadata: String? = nil,
    completion: ((Result<Refund, SeamlessPayError>) -> Void)?
  ) {
    let parameters: [String: Any?] = [
      "token": token,
      "amount": amount,
      "currency": currency,
      "descriptor": descriptor,
      "idempotencyKey": idempotencyKey,
      "metadata": metadata,
    ]

    execute(
      operation: .createRefund,
      parameters: parameters,
      map: { data in
        data.flatMap { try? Refund.decode($0) }
      },
      completion: completion
    )
  }
}

// MARK: - Private
// MARK: Request execution
private extension APIClient {
  func execute<ModelClass>(
    operation: APIOperation,
    parameters: [String: Any?]?,
    map: @escaping (Data?) -> ModelClass?,
    completion: ((Result<ModelClass, SeamlessPayError>) -> Void)?
  ) {
    do {
      let parameters = parameters?.compactMapValues { $0 }
      let request = try request(
        operation: operation,
        parameters: parameters
      )

      session.dataTask(
        with: request
      ) { [weak self] data, response, error in
        guard let self else {
          return
        }

        trackFailedRequest(request, response: response, responseData: data)

        let result: Result<ModelClass, SeamlessPayError>

        if error != nil || self.isResponseSuccessful(response) == false {
          result = .failure(
            .fromFailedSessionTask(data: data, error: error)
          )
        } else if let model = map(data) {
          result = .success(model)
        } else {
          result = .failure(.responseSerializationError)
        }

        DispatchQueue.main.async {
          completion?(result)
        }
      }
      .resume()

    } catch {
      DispatchQueue.main.async {
        completion?(
          .failure(
            .requestCreationError(error)
          )
        )
      }
    }
  }

  func isResponseSuccessful(_ response: URLResponse?) -> Bool {
    guard let response = response as? HTTPURLResponse else {
      return false
    }
    return (200 ..< 300).contains(response.statusCode)
  }
}

// MARK: Helpers
private extension APIClient {
  func customer(
    name: String? = nil,
    email: String? = nil,
    address: Address? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [PaymentMethod]? = nil,
    metadata: String? = nil,
    operation: APIOperation,
    completion: ((Result<Customer, SeamlessPayError>) -> Void)?
  ) {
    let parameters: [String: Any?] = [
      "name": name,
      "website": website,
      "address": address?.asParameter(),
      "companyName": companyName,
      "description": notes,
      "email": email,
      "phone": phone,
      "metadata": metadata,
      "paymentMethods": paymentMethods?.map(\.token),
    ]

    execute(
      operation: operation,
      parameters: parameters,
      map: { data in
        data.flatMap {
          try? Customer.decode($0)
        }
      },
      completion: completion
    )
  }

  func charge(
    token: String? = nil,
    cvv: String? = nil,
    capture: Bool? = nil,
    currency: String? = nil,
    amount: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderID: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    operation: APIOperation,
    completion: ((Result<Charge, SeamlessPayError>) -> Void)?
  ) {
    let parameters: [String: Any?] = [
      "token": token,
      "cvv": cvv,
      "capture": capture,
      "currency": currency,
      "amount": amount,
      "taxAmount": taxAmount,
      "taxExempt": taxExempt,
      "tip": tip,
      "surchargeFeeAmount": surchargeFeeAmount,
      "description": description,
      "orderID": orderID,
      "poNumber": poNumber,
      "descriptor": descriptor,
      "idempotencyKey": idempotencyKey,
      "entryType": entryType,
      "metadata": metadata,
      "order": order,
      "deviceFingerprint": deviceFingerprint,
    ]

    execute(
      operation: operation,
      parameters: parameters,
      map: { data in
        data.flatMap {
          try? Charge.decode($0)
        }
      },
      completion: completion
    )
  }
}

// MARK: Request builder
private extension APIClient {
  func request(
    operation: APIOperation,
    parameters: [String: Any]?
  ) throws -> URLRequest {
    let host: String?
    let authorization: String?

    switch operation {
    case .createToken:
      host = environment.panVaultHost
      authorization = publishableKey
    default:
      host = environment.mainHost
      authorization = secretKey
    }

    return try request(
      method: operation.method,
      path: operation.path,
      host: host,
      authorization: authorization,
      parameters: parameters
    )
  }

  func request(
    method: HTTPMethod,
    path: String,
    host: String?,
    authorization: String?,
    parameters: [String: Any]?
  ) throws -> URLRequest {
    let url = try url(
      host: host,
      path: path
    )
    var request = URLRequest(
      url: url,
      cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: 15.0
    )

    request.httpMethod = method.rawValue

    var postBody: Data?
    switch method {
    case .post,
         .put:
      postBody = try parameters.flatMap { try JSONSerialization.data(withJSONObject: $0) }
    default:
      postBody = nil
    }

    request.httpBody = postBody

    request.allHTTPHeaderFields = headers(
      authorization: authorization,
      contentLength: postBody?.count
    )

    return request
  }

  func url(host: String?, path: String, queryItems: [String: String]? = nil) throws -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = host
    urlComponents.port = nil
    urlComponents.path = path
    urlComponents.queryItems = queryItems?.map { URLQueryItem(name: $0, value: $1) }
    guard let url = urlComponents.url else {
      throw SeamlessPayInvalidURLError()
    }
    return url
  }

  func headers(
    authorization: String?,
    contentLength: Int?
  ) -> [String: String] {
    let authHeaderValue = authorization.flatMap { "Bearer " + $0 }
    let contentLength = contentLength.flatMap { String($0) }

    return [
      "API-Version": apiVersion,
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": authHeaderValue,
      "User-Agent": "seamlesspay_ios",
      "SeamlessPay-Account": subMerchantAccountId,
      "Content-Length": contentLength,
    ]
    .compactMapValues { $0 }
  }
}

// MARK: Sentry Client
private extension APIClient {
  func setSentryClient() {
//    #if !DEBUG // Initialize sentry client only for release builds
    sentryClient = SPSentryClient.makeWith(
      configuration: .init(
        userId: SPInstallation.installationID,
        environment: environment.name
      )
    )
//    #endif
  }

  func trackFailedRequest(
    _ request: URLRequest,
    response: URLResponse?,
    responseData: Data?
  ) {
    if isResponseSuccessful(response) == false {
      sentryClient?.captureFailedRequest(
        request,
        response: response,
        responseData: responseData
      )
    }
  }
}
