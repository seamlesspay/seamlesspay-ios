// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

public struct SDKConfiguration {
  let clientConfiguration: ClientConfiguration
  var data: SDKData? { try? result?.get() }

  private let result: Result<SDKData, SeamlessPayError>?

  public init(clientConfiguration: ClientConfiguration) async {
    self.clientConfiguration = clientConfiguration
    result = await APIClient(config: clientConfiguration).retrieveSDKData()
  }
}
