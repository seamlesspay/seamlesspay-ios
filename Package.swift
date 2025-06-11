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
  dependencies: [
    .package(path: "../swift-sentry-client-release"),
  ],
  targets: [
    .target(
      name: "SeamlessPay",
      dependencies: [
        "SeamlessPayObjC",
        .product(name: "SwiftSentryClient", package: "swift-sentry-client-release"),
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
