// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import XCTest
@testable import SeamlessPay

final class SPSentryHTTPEventFactoryTest: XCTestCase {
  func testSPSentryHTTPEventFactory() {
    let tokenKey = "token"
    let cvvKey = "cvv"
    let accountNumberKey = "accountNumber"
    let expDateKey = "expDate"
    let billingAddressKey = "billingAddress"
    let orderKey = "order"

    let mockToken = "mock.token"
    let mockLine1 = "mock.line1"
    let mockDescription = "mock.description"
    let mockAccountNumber = "mock.accountNumber"
    let mockCVV = "mock.cvv"
    let mockExpDate = "mock.expDate"

    // given
    var request = URLRequest(
      url: URL(
        string: "http://any.com"
      )!
    )
    let body: [String: Any] = [
      tokenKey: mockToken,
      billingAddressKey: [
        "line1": mockLine1,
      ],
      orderKey: [
        "items": [
          "description": mockDescription,
        ],
      ],
      cvvKey: mockCVV,
      accountNumberKey: mockAccountNumber,
      expDateKey: mockExpDate,
    ]
    request.httpBody = try! JSONSerialization.data(withJSONObject: body)

    // when
    let event: SPSentryHTTPEvent = SPSentryHTTPEventFactory.event(
      request: request,
      response: .init(),
      responseData: "{}".data(using: .utf8),
      sentryClientConfig: SPSentryConfig(
        userId: "uiser.id",
        environment: .PRO
      )
    )

    // then
    XCTAssertFalse(event.eventId.contains("-"))
    XCTAssertNotNil(event.request.data)

    let requestBody = event.request.data!

    XCTAssertEqual(requestBody[tokenKey]!, "***")
    XCTAssertEqual(requestBody[cvvKey]!, "***")
    XCTAssertEqual(requestBody[accountNumberKey]!, "***")
    XCTAssertEqual(requestBody[expDateKey]!, "***")

    XCTAssertNotNil(requestBody[billingAddressKey])
    XCTAssertNotNil(requestBody[orderKey])

    let requestBodyValues = Set(requestBody.values)
    let requestBodyKeys = Set(requestBody.keys)
    let mockValues = Set(
      [
        mockCVV,
        mockLine1,
        mockToken,
        mockDescription,
        mockExpDate,
        mockAccountNumber,
      ]
    )

    XCTAssertEqual(
      requestBodyValues.intersection(mockValues).count,
      0
    )

    XCTAssertEqual(
      requestBodyKeys.intersection(mockValues).count,
      0
    )
  }
}
