// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public class APIClient {
  // MARK: Private Constants
  private let apiVersion = "v2020"

  // MARK: Private
  private let secretKey: String?
  private let subMerchantAccountId: String?
  private var deviceFingerprint: String? {
    DeviceFingerprint.make(
      appOpenTime: appOpenTime,
      apiVersion: apiVersion
    )
  }

  private var appOpenTime: Date?
  private var sentryClient: SPSentryClient?

  // MARK: - Public Interface
  public private(set) var publishableKey: String
  public private(set) var environment: Environment = .sandbox

  // MARK: Init
  public init(
    secretKey: String? = nil,
    publishableKey: String,
    environment: Environment,
    subMerchantAccountId: String? = nil
  ) {
    self.secretKey = secretKey ?? publishableKey
    self.publishableKey = publishableKey
    self.environment = environment
    self.subMerchantAccountId = subMerchantAccountId

    appOpenTime = Date()

    setSentryClient()
  }

  // MARK: Tokenize
  public func tokenize(
    paymentType: PaymentType,
    accountNumber: String,
    expirationDate: String? = nil,
    cvv: String? = nil,
    accountType: String? = nil,
    routing: String? = nil,
    pin: String? = nil,
    billingAddress: SPAddress? = nil,
    name: String? = nil,
    completion: ((Result<SPPaymentMethod, SeamlessPayError>) -> Void)?
  ) {
    var optionalParameters: [String: Any?] = [
      "paymentType": paymentType.name,
      "accountNumber": accountNumber,
      "billingAddress": billingAddress?.dictionary(),
      "name": name,
      "deviceFingerprint": deviceFingerprint,
    ]

    switch paymentType {
    case .ach:
      optionalParameters["bankAccountType"] = accountType
      optionalParameters["routingNumber"] = routing
    case .creditCard:
      optionalParameters["expDate"] = expirationDate
      optionalParameters["cvv"] = cvv
    case .giftCard:
      optionalParameters["pinNumber"] = pin
    case .plDebitCard:
      optionalParameters["expDate"] = expirationDate
    }

    let parameters = optionalParameters.compactMapValues { $0 }

    execute(
      operation: .createToken,
      parameters: parameters,
      map: SPPaymentMethod.token(withResponseData:),
      completion: completion
    )
  }

  // MARK: Customer
  func createCustomer(
    name: String,
    email: String,
    address: SPAddress? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [SPPaymentMethod]? = nil,
    metadata: String? = nil,
    completion: ((Result<SPCustomer, SeamlessPayError>) -> Void)?
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

  func updateCustomer(
    id: String,
    name: String,
    email: String,
    address: SPAddress? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [SPPaymentMethod]? = nil,
    metadata: String? = nil,
    completion: ((Result<SPCustomer, SeamlessPayError>) -> Void)?
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

  func retrieveCustomer(
    id: String,
    completion: ((Result<SPCustomer, SeamlessPayError>) -> Void)?
  ) {
    customer(operation: .retrieveCharge(id: id), completion: completion)
  }

  // MARK: Charge
  func createCharge(
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
    orderId: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    completion: ((Result<SPCharge, SeamlessPayError>) -> Void)?
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
      orderId: orderId,
      poNumber: poNumber,
      metadata: metadata,
      descriptor: descriptor,
      entryType: entryType,
      idempotencyKey: idempotencyKey,
      operation: .createCharge,
      completion: completion
    )
  }

  func retrieveCharge(
    id: String,
    completion: ((Result<SPCharge, SeamlessPayError>) -> Void)?
  ) {
    charge(operation: .retrieveCharge(id: id), completion: completion)
  }

  func listCharges(
    completion: ((Result<[String: Any], SeamlessPayError>) -> Void)?
  ) {
    execute(
      operation: .listCharges,
      parameters: nil,
      map: { data in
        // TODO: Transform to model
        data.flatMap {
          try? JSONSerialization.jsonObject(with: $0, options: .allowFragments)
        } as? [String: Any]
      },
      completion: completion
    )
  }

  // MARK: Verify
  func verify(
    token: String,
    cvv: String? = nil,
    currency: String? = nil,
    taxAmount: String? = nil,
    taxExempt: Bool? = nil,
    tip: String? = nil,
    surchargeFeeAmount: String? = nil,
    description: String? = nil,
    order: [String: String]? = nil,
    orderId: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    completion: ((Result<SPCharge, SeamlessPayError>) -> Void)?
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
      orderId: orderId,
      poNumber: poNumber,
      metadata: metadata,
      descriptor: descriptor,
      entryType: entryType,
      idempotencyKey: idempotencyKey,
      operation: .createCharge,
      completion: completion
    )
  }
}

// MARK: - Request execution
private extension APIClient {
  func execute<ModelClass>(
    operation: APIOperation,
    parameters: [String: Any]?,
    map: @escaping (Data?) -> ModelClass?,
    completion: ((Result<ModelClass, SeamlessPayError>) -> Void)?
  ) {
    do {
      let request = try request(
        operation: operation,
        parameters: parameters
      )

      let session = URLSession(configuration: .default)
      session.dataTask(
        with: request
      ) { [weak self] data, response, error in
        guard let self else {
          return
        }

        trackFailedRequest(request, response: response, responseData: data)

        let result: Result<ModelClass, SeamlessPayError>

        if error != nil || !self.isResponseSuccessful(response) {
          result = .failure(
            .apiError(
              .init(
                data: data,
                error: error
              )
            )
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

// MARK: - Private

// MARK: API operation
private extension APIClient {
  enum APIOperation {
    case createToken
    case createCustomer
    case updateCustomer(id: String)
    case retrieveCustomer(id: String)
    case createCharge
    case retrieveCharge(id: String)
    case listCharges

    var path: String {
      let body: String
      switch self {
      case .createToken:
        body = "tokens"
      case .createCustomer:
        body = "customers"
      case let .retrieveCharge(value),
           let .retrieveCustomer(value),
           let .updateCustomer(value):
        body = ["customers", value].joined(separator: "/")
      case .createCharge,
           .listCharges:
        body = "changes"
      }
      return "/" + body
    }

    var method: HTTPMethod {
      switch self {
      case .createCharge,
           .createCustomer,
           .createToken:
        return .post
      case .updateCustomer:
        return .put
      case .listCharges,
           .retrieveCharge,
           .retrieveCustomer:
        return .get
      }
    }
  }
}

// MARK: Helpers
private extension APIClient {
  func customer(
    name: String? = nil,
    email: String? = nil,
    address: SPAddress? = nil,
    companyName: String? = nil,
    notes: String? = nil,
    phone: String? = nil,
    website: String? = nil,
    paymentMethods: [SPPaymentMethod]? = nil,
    metadata: String? = nil,
    operation: APIOperation,
    completion: ((Result<SPCustomer, SeamlessPayError>) -> Void)?
  ) {
    let parametersOptional: [String: Any?] = [
      "name": name,
      "website": website,
      "address": address?.dictionary(),
      "companyName": companyName,
      "description": notes,
      "email": email,
      "phone": phone,
      "metadata": metadata ?? "metadata",
      "paymentMethods": paymentMethods?.map { $0.token },
    ]

    let parameters = parametersOptional.compactMapValues { $0 }

    execute(
      operation: operation,
      parameters: parameters,
      map: {
        $0.flatMap(SPCustomer.init(responseData:))
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
    orderId: String? = nil,
    poNumber: String? = nil,
    metadata: String? = nil,
    descriptor: String? = nil,
    entryType: String? = nil,
    idempotencyKey: String? = nil,
    operation: APIOperation,
    completion: ((Result<SPCharge, SeamlessPayError>) -> Void)?
  ) {
    let parametersOptional: [String: Any?] = [
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
      "orderID": orderId,
      "poNumber": poNumber,
      "descriptor": descriptor,
      "idempotencyKey": idempotencyKey,
      "entryType": entryType,
      "metadata": metadata,
      "order": order,
      "deviceFingerprint": deviceFingerprint,
    ]
    let parameters = parametersOptional.compactMapValues { $0 }

    execute(
      operation: operation,
      parameters: parameters,
      map: {
        $0.flatMap(SPCharge.init(responseData:))
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
    let host: String
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
    host: String,
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

  func url(host: String, path: String, queryItems: [String: String]? = nil) throws -> URL {
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
    let authHeaderValue = authorization?
      .data(using: .utf8)
      .flatMap { $0.base64EncodedString(options: []) }
      .flatMap { "Bearer " + $0 }
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
      .init(
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
    if isResponseSuccessful(response) {
      sentryClient?.captureFailedRequest(
        request,
        response: response,
        responseData: responseData
      )
    }
  }
}
