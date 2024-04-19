// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPay

struct MultiLineCardFormVCContent: View {
  var cardFormUI = MultiLineCardFormUI()

  var body: some View {
    VStack {
      cardFormUI

      Button {
        cardFormUI.submit()
      } label: {
        Text("Pay")
          .font(.system(size: 22))
          .foregroundColor(.white)
          .padding()
          .background(Color.blue)
          .cornerRadius(5)
      }
    }
    .padding(20)
  }
}

struct MultiLineCardFormUI: UIViewRepresentable {
  let cardForm = MultiLineCardForm(
    authorization: sharedSPAuthorization,
    fieldOptions: .default
  )

  func makeUIView(context: Context) -> MultiLineCardForm {
    return cardForm
  }

  func updateUIView(_ uiView: MultiLineCardForm, context: Context) {}

  func submit() {}
}
