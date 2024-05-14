// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPay

struct CardFormContent: View {
  enum CardFormContentType {
    case single
    case multi
  }

  struct DisplayResult {
    let header: String
    let payload: String
  }

  let cardForm: CardForm
  @State var displayResult: DisplayResult = .init(header: "RESULT", payload: "")
  @State var inProgress: Bool = false

  init(authorization: Authorization, type: CardFormContentType) {
    let fieldOptions = FieldOptions.default

    switch type {
    case .single:
      cardForm = SingleLineCardForm(authorization: authorization, fieldOptions: fieldOptions)
    case .multi:
      cardForm = MultiLineCardForm(authorization: authorization, fieldOptions: fieldOptions)
    }
  }

  var body: some View {
    List {
      Group {
        Section(header: Text("Card Form")) {
          CardFormUI(cardForm: cardForm)
            .frame(height: 300)
        }

        Section(header: Text("Capabilities")) {
          HStack {
            Button {
              startProgress()
              cardForm.tokenize {
                processResult($0)
              }
            } label: {
              Text("Tokenize")
            }
            .buttonStyle(.borderedProminent)

            Button {
              startProgress()
              cardForm.submit(.init(amount: "101")) {
                processResult($0)
              }
            } label: {
              Text("Pay")
            }
            .buttonStyle(.borderedProminent)

            Button {
              startProgress()
              cardForm.refund(.init(amount: "10")) {
                processResult($0)
              }
            } label: {
              Text("Refund")
            }
            .buttonStyle(.borderedProminent)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }

        Section(
          header: Text(displayResult.header)
        ) {
          VStack {
            if inProgress {
              ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Text(displayResult.payload)
              .lineLimit(.none)
              .listRowSeparator(.hidden)
          }
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
    }
  }

  private func processResult(
    _ result: Result<some CustomDebugStringConvertible, SeamlessPayError>
  ) {
    inProgress = false
    switch result {
    case let .success(payload):
      displayResult = .init(header: "SUCCESS", payload: payload.debugDescription)
    case let .failure(error):
      displayResult = .init(header: "FAILURE", payload: error.localizedDescription)
    }
  }

  private func startProgress() {
    inProgress = true
    displayResult = .init(header: "RESULT", payload: "")
  }
}

struct CardFormUI: UIViewRepresentable {
  private let cardForm: CardForm

  init(cardForm: CardForm) {
    self.cardForm = cardForm
  }

  func makeUIView(context: Context) -> CardForm {
    return cardForm
  }

  func updateUIView(_ uiView: CardForm, context: Context) {}

  func makeCoordinator() -> CardFormUICoordinator {
    CardFormUICoordinator(cardFormUI: self)
  }
}

class CardFormUICoordinator: NSObject, CardFormDelegate {
  let cardFormUI: CardFormUI
  init(cardFormUI: CardFormUI) {
    self.cardFormUI = cardFormUI
  }

  // MARK: CardFormDelegate
  func cardFormDidChange(_ view: CardForm) {}
}
