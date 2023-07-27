// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

final class SPSentryClientMockURLProtocol: URLProtocol {
  enum ResponseType {
    case error(Error)
    case success(Data, HTTPURLResponse)
  }

  static var responseType: ResponseType!

  // this dictionary maps URLs to test data
  static var testURLs = [URL?: Data]()

  // say we want to handle all types of request
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  // ignore this method; just send back what we were given
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    switch SPSentryClientMockURLProtocol.responseType! {
    case let .success(data, response):
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    case let .error(error):
      client?.urlProtocol(self, didFailWithError: error)
    }

    client?.urlProtocolDidFinishLoading(self)
  }

  // this method is required but doesn't need to do anything
  override func stopLoading() {}
}

extension SPSentryClientMockURLProtocol {
  enum MockError: Error {
    case none
  }

  static func responseWithFailure() {
    SPSentryClientMockURLProtocol.responseType = .error(MockError.none)
  }

  static func responseWithSuccess() {
    let response = HTTPURLResponse(
      url: URL(string: "http://any.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!

    let data = Data("Any data".utf8)

    SPSentryClientMockURLProtocol.responseType = .success(data, response)
  }
}
