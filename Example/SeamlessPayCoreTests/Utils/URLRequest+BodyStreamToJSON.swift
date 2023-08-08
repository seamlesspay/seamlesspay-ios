// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

extension URLRequest {
  func bodySteamAsJSON() -> [String: Any]? {
    guard let bodyStream = httpBodyStream else { return nil }

    bodyStream.open()

    // Will read 16 chars per iteration. Can use bigger buffer if needed
    let bufferSize = 16

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

    var dat = Data()

    while bodyStream.hasBytesAvailable {
      let readDat = bodyStream.read(buffer, maxLength: bufferSize)
      dat.append(buffer, count: readDat)
    }

    buffer.deallocate()

    bodyStream.close()

    do {
      return try JSONSerialization.jsonObject(
        with: dat,
        options: JSONSerialization.ReadingOptions.allowFragments
      ) as? [String: Any]
    } catch {
      print(error.localizedDescription)

      return nil
    }
  }
}
