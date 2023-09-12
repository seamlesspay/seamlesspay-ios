// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import SwiftUI
import SeamlessPayCore

private enum VerificationState {
  case idle
  case verifying
  case verified(Result<SPCharge, SPError>)

  var isVerifying: Bool {
    switch self {
    case .verifying:
      return true
    default:
      return false
    }
  }
}

struct VerificationView: View {
  @State private var token: String = ""
  @State private var verificationState: VerificationState = .idle

  @State private var firstName = ""
  @State private var lastName = ""
  @FocusState private var tokenFieldIsFocused: Bool

  init() {
    if let savedPaymentMethod = UserDefaults.standard.dictionary(forKey: "paymentMethod"),
       let savedToken = savedPaymentMethod["token"] as? String {
      _token = State(initialValue: savedToken)
    }
  }

  var body: some View {
    ZStack {
      Form {
        Section(
          header: Text("Token"),
          content: {
            TextField("Enter your token", text: $token)
              .font(Font.system(size: 16, design: .default))
              .focused($tokenFieldIsFocused)
          }
        )
        Section(
          header: Text("Result"),
          content: {
            switch verificationState {
            case .idle:
              EmptyView()
            case .verifying:
              Text("Verifying...")
            case let .verified(result):
              switch result {
              case let .success(charge):
                SPChargeDetailView(viewModel: charge)
              case let .failure(error):
                SPDetailErrorView(viewModel: error)
              }
            }
          }
        )
      }
      .onAppear {
        self.tokenFieldIsFocused = true
      }
      VStack {
        Spacer()
        Button(
          action: {
            self.verifyToken()
          },
          label: {
            if verificationState.isVerifying {
              ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            } else {
              Text("Verify")
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
          }
        )
        .padding()
        .disabled(verificationState.isVerifying)
      }
    }
  }

  private func verifyToken() {
    verificationState = .verifying
    tokenFieldIsFocused = false

    let cli = SeamlessPayCore.APIClient.shared
    cli.set(secretKey: nil, publishableKey: "pk_XXX", environment: .production)
    cli.tokenize(
      paymentType: .ach,
      accountNumber: "",
      expirationDate: "",
      cvv: "",
      accountType: "",
      routing: "",
      pin: "",
      billingAddress: .init(),
      name: ""
    ) { result in
      switch result {
      case let .success(paymentMethod):
        print("here = ", paymentMethod)
      case let .failure(error):
        print("error = ", error)
      }
    }

    SPAPIClient.getSharedInstance().verify(
      withToken: token,
      success: { charge in
        DispatchQueue.main.async {
          verificationState = .verified(Result.success(charge))
        }
      },
      failure: { error in
        DispatchQueue.main.async {
          verificationState = .verified(Result.failure(error))
        }
      }
    )
  }
}

struct VerificationView_Previews: PreviewProvider {
  static var previews: some View {
    VerificationView()
  }
}
