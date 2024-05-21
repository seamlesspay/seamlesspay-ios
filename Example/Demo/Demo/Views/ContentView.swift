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
  @State private var isSheet1Presented = false
  @State private var isSheet2Presented = false

  var body: some View {
    NavigationView {
      List {
        Section {
          Text("Singleline Card Form")
            .onTapGesture {
              self.isSheet1Presented = true
            }
          Text("Multiline Card Form")
            .onTapGesture {
              self.isSheet2Presented = true
            }
        } header: {
          Text("UI Components")
        }
      }
      .sheet(isPresented: $isSheet1Presented) {
        NavigationStack {
          CardFormContent(
            authorization: .init(
              environment: DemoAuth.environment,
              secretKey: DemoAuth.secretKey
            ),
            type: .single
          )
          .navigationBarItems(
            trailing: Button("Done") {
              self.isSheet1Presented = false
            }
          )
        }
      }
      .sheet(isPresented: $isSheet2Presented) {
        NavigationStack {
          CardFormContent(
            authorization: .init(
              environment: DemoAuth.environment,
              secretKey: DemoAuth.secretKey
            ),
            type: .multi
          )
          .navigationBarItems(
            trailing: Button("Done") {
              self.isSheet2Presented = false
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
