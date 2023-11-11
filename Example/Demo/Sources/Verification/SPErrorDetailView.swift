// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPayCore

struct SPDetailErrorView: View {
  var viewModel: SeamlessPayError

  var body: some View {
    VStack(alignment: .leading) {
      KeyValueRow(
        key: "Error Code",
        value: viewModel.errorCodeString
      )
      KeyValueRow(key: "Error Description", value: viewModel.localizedDescription)
    }
  }
}

private extension SeamlessPayError {
  var errorCodeString: String {
    guard case let .apiError(error) = self else {
      return .init()
    }

    return error.code.description
  }
}

struct SPDetailErrorView_Previews: PreviewProvider {
  static var previews: some View {
    SPDetailErrorView(
      viewModel: .apiError(
        .init(
          domain: "domain",
          code: 0,
          userInfo: [:]
        )
      )
    )
  }
}
