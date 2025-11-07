// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

final class APIClientURLProtocolMock: URLProtocol {
  enum ResponseType {
    case error(Error)
    case success(Data, HTTPURLResponse)
  }

  static var responseType: ResponseType!
  static var testingRequest: URLRequest?

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    Self.testingRequest = request

    switch Self.responseType! {
    case let .success(data, response):
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    case let .error(error):
      client?.urlProtocol(self, didFailWithError: error)
    }

    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

// MARK: APIClientURLProtocolMock Helpers
extension APIClientURLProtocolMock {
  enum MockError: Error {
    case some
  }

  static func setFailureResponse() {
    responseType = .error(MockError.some)
  }
  
  static func setSuccessResponse(data: Data, statusCode: Int = 200) {
    let response = HTTPURLResponse(
      url: URL(string: "http://test.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"]
    )!
    responseType = .success(data, response)
  }
  
  static func setErrorResponse(data: Data, statusCode: Int) {
    let response = HTTPURLResponse(
      url: URL(string: "http://test.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"]
    )!
    responseType = .success(data, response)
  }
}
