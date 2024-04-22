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
        .frame(height: 300)
        .padding(20)

      Button {
        cardFormUI.submit(.init(amount: "101")) { _ in }
      } label: {
        Text("Pay")
          .font(.system(size: 22))
          .foregroundColor(.white)
          .padding()
          .background(Color.blue)
          .cornerRadius(5)
      }
    }
  }
}

struct MultiLineCardFormUI: UIViewRepresentable {
  let cardForm = MultiLineCardForm(
    authorization: sharedSPAuthorization,
    fieldOptions: .init(cvv: .init(display: .optional), postalCode: .init(display: .optional))
  )

  func makeUIView(context: Context) -> MultiLineCardForm {
    return cardForm
  }

  func updateUIView(_ uiView: MultiLineCardForm, context: Context) {}

  func makeCoordinator() -> MultiLineCardFormUICoordinator {
    MultiLineCardFormUICoordinator(cardFormUI: self)
  }

  func submit(
    _ request: PaymentRequest,
    completion: ((Result<PaymentResponse, SeamlessPayError>) -> Void)?
  ) {
    cardForm.submit(request, completion: completion)
  }
}

class MultiLineCardFormUICoordinator: NSObject, CardFormDelegate {
  let cardFormUI: MultiLineCardFormUI
  init(cardFormUI: MultiLineCardFormUI) {
    self.cardFormUI = cardFormUI
  }

  // MARK: CardFormDelegate
  func cardFormDidChange(_ view: CardForm) {}
}
