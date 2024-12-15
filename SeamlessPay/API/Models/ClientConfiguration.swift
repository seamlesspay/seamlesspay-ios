// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct ClientConfiguration {
  public let environment: Environment
  public let secretKey: String
  public let proxyAccountId: String?

  public init(environment: Environment, secretKey: String, proxyAccountId: String? = nil) {
    self.secretKey = secretKey
    self.proxyAccountId = proxyAccountId
    self.environment = environment
  }
}

public struct SDKConfiguration {

  let clientConfiguration: ClientConfiguration
  let applePayMerchantId: String?

  public init(environment: Environment, secretKey: String, proxyAccountId: String? = nil) async {
    clientConfiguration = ClientConfiguration(
      environment: environment,
      secretKey: secretKey,
      proxyAccountId: proxyAccountId
    )
    applePayMerchantId = await Self.getSDKData(config: clientConfiguration)
  }

  public init(clientConfiguration: ClientConfiguration) async {
    self.clientConfiguration = clientConfiguration
    applePayMerchantId = await Self.getSDKData(config: clientConfiguration)
  }

  static func getSDKData(config: ClientConfiguration) async -> String? {
    await withCheckedContinuation { continuation in
      let client = APIClient(config: config)
      client.sdkData { result in
        let applePayMerchantId = try? result.get().applePay?.merchantId
        continuation.resume(returning: applePayMerchantId)
      }
    }
  }
}
