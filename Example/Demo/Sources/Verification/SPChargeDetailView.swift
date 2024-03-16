// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPay

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

struct SPChargeDetailViewModel {
  let id: String?
  let method: String?
  let amount: String?
  let tip: String?
  let currency: String?
  let status: String?
}

struct SPChargeDetailView: View {
  var viewModel: SPChargeDetailViewModel

  var body: some View {
    VStack(alignment: .leading) {
      KeyValueRow(key: "Charge ID", value: viewModel.id ?? "")
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
    SPChargeDetailView(
      viewModel: .init(
        id: "some_id",
        method: "method",
        amount: "101.1",
        tip: "20",
        currency: "USD",
        status: "some_status"
      )
    )
  }
}
