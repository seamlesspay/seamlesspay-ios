// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SeamlessPayCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "SeamlessPayCore",
      targets: [
        "SeamlessPayCore",
      ]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "SeamlessPayCore",
      dependencies: ["SeamlessPayCoreObjC"],
      path: "SeamlessPayCore"
    ),
    .target(
      name: "SeamlessPayCoreObjC",
      dependencies: [],
      path: "SeamlessPayCoreObjC"
    ),
    .testTarget(
      name: "SeamlessPayCoreTests",
      dependencies: [
        "SeamlessPayCore",
        "SeamlessPayCoreObjC",
      ]
    ),
    .testTarget(
      name: "SeamlessPayCoreTestsObjC",
      dependencies: [
        "SeamlessPayCore",
        "SeamlessPayCoreObjC",
      ]
    ),
  ]
)
