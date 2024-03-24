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
      dependencies: ["SeamlessPayObjC", "SeamlessPayAPI", "SeamlessPayUI"],
      path: "SeamlessPay"
    ),
    .target(
      name: "SeamlessPayObjC",
      dependencies: ["SeamlessPayAPI"],
      path: "ObjC",
//      sources: [
//        "include/",
//      ],
      resources: [
        .process("Resources/Assets"),
      ],
      publicHeadersPath: "include"
    ),
    .target(
      name: "SeamlessPayUI",
      dependencies: ["SeamlessPayObjC", "SeamlessPayAPI"],
      path: "UI"
    ),
    .target(
      name: "SeamlessPayAPI",
      dependencies: [],
      path: "API"
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
