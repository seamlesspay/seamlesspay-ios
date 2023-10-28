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
    // Products define the executables and libraries a package produces, and make them visible to
    // other packages.
    .library(
      name: "SeamlessPay",
      targets: ["SeamlessPay"]
    ),
    .library(
      name: "SeamlessPayObjC",
      targets: ["SeamlessPayObjC"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test
    // suite.
    // Targets can depend on other targets in this package, and on products in packages this package
    // depends on.
    .target(
      name: "SeamlessPay",
      dependencies: ["SeamlessPayObjC"],
      path: "SeamlessPay"
    ),
    .target(
      name: "SeamlessPayObjC",
      dependencies: [],
      path: "SeamlessPayObjC"
    ),
    .testTarget(
      name: "SeamlessPayTests",
      dependencies: ["SeamlessPay", "SeamlessPayObjC"]
    ),
    .testTarget(
      name: "SeamlessPayTestsObjC",
      dependencies: ["SeamlessPay", "SeamlessPayObjC"]
    ),
  ]
)
