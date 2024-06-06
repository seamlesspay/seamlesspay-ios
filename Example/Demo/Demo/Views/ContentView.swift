//
//  ContentView.swift
//  Demo
//
//  Created by macuser on 08.05.2024.
//

import SwiftUI
import SeamlessPay

enum DemoAuth {
  static let secretKey: String = "sk_01HV75FH87CCT098427ZVEKQHZ"
  static let environment: SeamlessPay.Environment = .staging
}

struct ContentView: View {
  @State private var cardFormContentType: CardFormContentType?

  var body: some View {
    NavigationView {
      List {
        Section {
          Text("Singleline Card Form")
            .onTapGesture {
              self.cardFormContentType = .single
            }
          Text("Multiline Card Form")
            .onTapGesture {
              self.cardFormContentType = .multi
            }
        } header: {
          Text("UI Components")
        }
      }
      .sheet(item: $cardFormContentType) { contentType in
        NavigationStack {
          CardFormContent(
            authorization: .init(
              secretKey: DemoAuth.secretKey,
              environment: DemoAuth.environment
            ),
            type: contentType
          )
          .navigationBarItems(
            trailing: Button("Done") {
              self.cardFormContentType = .none
            }
          )
        }
      }
      .navigationTitle("SeamlessPay UI Demo")
    }
  }
}

#Preview {
  ContentView()
}

extension SeamlessPay.Environment: Identifiable {
  public var id: Int {
    rawValue
  }
}
