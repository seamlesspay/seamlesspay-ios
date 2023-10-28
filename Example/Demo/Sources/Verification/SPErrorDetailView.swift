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
      KeyValueRow(key: "Error Code", value: "\(viewModel.spError.code)")
      KeyValueRow(key: "Error Description", value: viewModel.localizedDescription)
    }
  }
}

struct SPDetailErrorView_Previews: PreviewProvider {
  static var previews: some View {
    SPDetailErrorView(viewModel: .apiError(SPError.unknownError()))
  }
}
