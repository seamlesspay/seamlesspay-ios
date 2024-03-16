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
  ],
  targets: [
    .target(
      name: "SeamlessPay",
      dependencies: ["SeamlessPayObjC"],
      path: "SeamlessPay"
    ),
    .target(
      name: "SeamlessPayObjC",
      dependencies: [],
      path: "SeamlessPayObjC",

      resources: [
        .process("Resources/Assets"),
      ]
    ),
    .testTarget(
      name: "SeamlessPayTests",
      dependencies: [
        "SeamlessPay",
        "SeamlessPayObjC",
      ]
    ),
    .testTarget(
      name: "SeamlessPayTestsObjC",
      dependencies: [
        "SeamlessPay",
        "SeamlessPayObjC",
      ]
    ),
  ]
)
