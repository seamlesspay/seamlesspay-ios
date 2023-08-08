// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPayCore

struct KeyValueRow: View {
  var key: String
  var value: String

  var body: some View {
    HStack(alignment: .top) {
      Text("\(key):")
        .font(.headline)
      Text("\(value)")
    }
  }
}

struct SPChargeDetailView: View {
  var viewModel: SPCharge

  var body: some View {
    VStack(alignment: .leading) {
      KeyValueRow(key: "Charge ID", value: viewModel.chargeId ?? "")
      KeyValueRow(key: "Method", value: viewModel.method ?? "")
      KeyValueRow(key: "Amount", value: viewModel.amount ?? "")
      KeyValueRow(key: "Tip", value: viewModel.tip ?? "")
      KeyValueRow(key: "Currency", value: viewModel.currency ?? "")
      KeyValueRow(key: "Status", value: viewModel.status ?? "")
    }
  }
}

struct SPChargeDetailView_Previews: PreviewProvider {
  static var previews: some View {
    SPChargeDetailView(viewModel: SPCharge())
  }
}
