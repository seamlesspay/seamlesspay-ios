// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

struct SPSentryDSN {
  let url: URL
  let baseEndpoint: URL
  let storeEndpoint: URL

  private static func makeBaseEndpoint(url: URL) -> URL? {
    let projectId = url.lastPathComponent
    var paths = url.pathComponents

    var path = ""
    if paths.count > 2 {
      paths.removeFirst()
      paths.removeLast()
      path = "/" + paths.joined(separator: "/")
    }

    var components = URLComponents()
    components.scheme = url.scheme
    components.host = url.host
    components.port = url.port
    components.path = "\(path)/api/\(projectId)/"

    return components.url
  }

  init?(string: String) {
    guard let url = URL(string: string),
          let baseEndpoint = Self.makeBaseEndpoint(url: url) else {
      return nil
    }
    self.url = url
    self.baseEndpoint = baseEndpoint
    storeEndpoint = baseEndpoint.appendingPathComponent("store/")
  }
}
