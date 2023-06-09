// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FeatherBlurView",
    platforms: [.iOS(.v17)],
    products: [.library(name: "FeatherBlurView", targets: ["FeatherBlurView"])],
    targets: [.target(name: "FeatherBlurView")]
)
