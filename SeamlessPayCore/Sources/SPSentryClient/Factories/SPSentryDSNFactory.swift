// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: Interface
enum SPSentryDSNFactory {
  static func dsn(urlString: String) -> SPSentryDSN? {
    guard let url = URL(string: urlString),
          let baseEndpoint = makeBaseEndpoint(url: url) else {
      return nil
    }

    return .init(
      url: url,
      baseEndpoint: baseEndpoint,
      storeEndpoint: baseEndpoint.appendingPathComponent("store/")
    )
  }
}

// MARK: Private
private extension SPSentryDSNFactory {
  static func makeBaseEndpoint(url: URL) -> URL? {
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
}
