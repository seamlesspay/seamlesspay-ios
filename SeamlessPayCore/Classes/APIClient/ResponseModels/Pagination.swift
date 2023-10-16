// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import Foundation

// MARK: - Pagination
public class Pagination: NSObject, Codable {
  public let count, page, pages, size: Int

  public init(count: Int, page: Int, pages: Int, size: Int) {
    self.count = count
    self.page = page
    self.pages = pages
    self.size = size
  }
}
