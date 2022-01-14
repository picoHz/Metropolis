// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Metropolis",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "Metropolis",
            targets: ["Metropolis"])
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Get", from: "0.4.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "Metropolis",
            dependencies: ["Get", "SwiftyJSON"]),
        .testTarget(
            name: "MetropolisTests",
            dependencies: ["Metropolis", "SwiftyJSON"])
    ]
)
