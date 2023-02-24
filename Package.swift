// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCParserCLI",
    platforms: [
        .macOS(.v11),
        .iOS(.v11)
    ],
    products: [
        .executable(name: "mcp", targets: ["MCParserCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
        .package(url: "https://github.com/yechentide/CoreBedrock", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "MCParserCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CoreBedrock", package: "CoreBedrock")
            ]),
        // .testTarget(
        //     name: "MCParserCLITests",
        //     dependencies: ["MCParserCLI"]),
    ]
)
