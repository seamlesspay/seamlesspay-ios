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
      dependencies: ["ObjC", "API", "UI"],
      path: "SeamlessPay"
    ),
    .target(
      name: "ObjC",
      dependencies: ["API"],
      path: "ObjC",
      sources: [
        "include/",
      ],
      resources: [
        .process("Resources/Assets"),
      ],
      publicHeadersPath: "include"
    ),
    .target(
      name: "UI",
      dependencies: ["ObjC", "API"],
      path: "UI"
    ),
    .target(
      name: "API",
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
        "ObjC",
      ]
    ),
  ]
)
