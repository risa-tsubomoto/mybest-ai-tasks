// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyBestAITasksCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyBestAITasksCore",
            targets: ["MyBestAITasksCore"]),
    ],
    dependencies: [
     // The Swift Programming Language
// https://docs.swift.org/swift-book

// MyBestAITasksCore Package
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyBestAITasksCore",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]),
    ]
)
