// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyBestAITasksCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MyBestAITasksCore",
            targets: ["MyBestAITasksCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MyBestAITasksCore",
            dependencies: []),
    ]
)
