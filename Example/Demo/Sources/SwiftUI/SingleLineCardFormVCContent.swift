// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPay

struct SingleLineCardFormVCContent: View {
  var cardFormUI = SingleLineCardFormUI()

  var body: some View {
    VStack {
      cardFormUI

      Button {
        cardFormUI.submit()
      } label: {
        Text("Pay with Single line card form")
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

struct SingleLineCardFormUI: UIViewRepresentable {
  let cardForm = SingleLineCardForm(
    authorization: sharedSPAuthorization,
    fieldOptions: .default
  )

  func makeUIView(context: Context) -> SingleLineCardForm {
    return cardForm
  }

  func updateUIView(_ uiView: SingleLineCardForm, context: Context) {}

  func submit() {}
}
