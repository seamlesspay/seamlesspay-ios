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

  static var requestData: [String: Any]?

    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  // ignore this method; just send back what we were given
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    Self.requestData = request.bodySteamAsJSON()

    switch Self.responseType! {
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
    Self.responseType = .error(MockError.none)
    Self.requestData = nil
  }

  static func responseWithSuccess() {
    let response = HTTPURLResponse(
      url: URL(
        string: "http://any.com"
      )!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!

    let data = Data("Any data".utf8)

    Self.responseType = .success(data, response)
    Self.requestData = nil
  }
}

private extension URLRequest {
  func bodySteamAsJSON() -> [String: Any]? {
    guard let bodyStream = httpBodyStream else { return nil }

    bodyStream.open()

    // Will read 16 chars per iteration. Can use bigger buffer if needed
    let bufferSize = 16

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

    var dat = Data()

    while bodyStream.hasBytesAvailable {
      let readDat = bodyStream.read(buffer, maxLength: bufferSize)
      dat.append(buffer, count: readDat)
    }

    buffer.deallocate()

    bodyStream.close()

    do {
      return try JSONSerialization.jsonObject(
        with: dat,
        options: JSONSerialization.ReadingOptions.allowFragments
      ) as? [String: Any]
    } catch {
      print(error.localizedDescription)

      return nil
    }
  }
}
