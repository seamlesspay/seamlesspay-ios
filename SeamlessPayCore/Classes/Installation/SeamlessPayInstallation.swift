// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

import Foundation

@objc public class SeamlessPayInstallation: NSObject {
  @objc public static var installationID: String {
    let cachesDirectory = NSSearchPathForDirectoriesInDomains(
      .cachesDirectory,
      .userDomainMask,
      true
    )

    guard !cachesDirectory.isEmpty, let cachePath = cachesDirectory.first else {
      return "undefined"
    }

    let installationFilePath = cachePath.appending("/SeamlessPay-InstallationID")

    if let installationData = try? Data(contentsOf: .init(fileURLWithPath: installationFilePath)),
       let id = String(data: installationData, encoding: .utf8) {
      return id
    }

    let id = UUID().uuidString

    if let installationStringData = id.data(using: .utf8) {
      FileManager.default.createFile(
        atPath: installationFilePath,
        contents: installationStringData,
        attributes: nil
      )
    }

    return id
  }
}
