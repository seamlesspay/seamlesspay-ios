// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SeamlessPay",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "SeamlessPay",
      targets: [
        "SeamlessPay",
      ]
    ),
  ],
  targets: [
    .target(
      name: "SeamlessPay",
      dependencies: [
        "SeamlessPayObjC",
        "SwiftSentryClient"
      ],
      path: "SeamlessPay"
    ),
    .target(
      name: "SeamlessPayObjC",
      dependencies: [],
      path: "ObjC",
      sources: [
        "include/",
      ],
      resources: [
        .process("Resources/Assets"),
      ],
      publicHeadersPath: "include"
    ),
    .binaryTarget(
      name: "SwiftSentryClient",
      path: "SwiftSentryClient/SwiftSentryClient.xcframework"
    ),
    .testTarget(
      name: "SeamlessPayTests",
      dependencies: [
        "SeamlessPay",
      ]
    ),
    .testTarget(
      name: "SeamlessPayTestsObjC",
      dependencies: [
        "SeamlessPayObjC",
      ]
    ),
  ]
)
