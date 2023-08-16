// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

@objc(SPPAPIClient) public class APIClient: NSObject {
  // MARK: Public Interface
  @objc public static let shared = APIClient()
  public private(set) var _publishableKey: String?
  public private(set) var _environment: Environment = .sandbox

  // MARK: Private Constants
  private enum Constants {
    static let k_APIVersion = "v2020"
    static let k_TimeoutInterval: TimeInterval = 15.0
  }

  // MARK: Private
  private var _APIHostURL: String?
  private var _PanVaultHostURL: String?
  private var _secretKey: String?

  private var appOpenTime: Date?
  private var sentryClient: SPSentryClient?

  // MARK: Init
  override init() {}

  // MARK: Public Interface
  @objc public func setSecretKey(
    _ secretKey: String?,
    publishableKey: String?,
    environment: Environment
  ) {
    _APIHostURL = environment.baseURL
    _PanVaultHostURL = environment.panVaultBaseURL

    _secretKey = secretKey ?? publishableKey
    _publishableKey = publishableKey
    _environment = environment

    setSentryClient()

    appOpenTime = Date()
  }
}

// MARK: Sentry Client
private extension APIClient {
  private func setSentryClient() {
    #if !DEBUG // Initialize sentry client only for release builds
      sentryClient = SPSentryClient.make(
        with: .init(
          userId: SPInstallation.installationID(),
          environment: valueForEnvironment()
        )
      )
    #endif
  }
}
