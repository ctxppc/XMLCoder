// swift-tools-version:5.1
// XMLCoder © 2019 Creatunit

import PackageDescription

let package = Package(
    name: "XMLCoder",
	platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "XMLCoder", targets: ["XMLCoder"]),
    ],
    dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", from: "0.7.0")],
    targets: [
        .target(name: "XMLCoder", dependencies: ["DepthKit"]),
        .testTarget(name: "XMLCoderTests", dependencies: ["XMLCoder"])
    ]
)
