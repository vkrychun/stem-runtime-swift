// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StemRuntimeSDK",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "StemRuntimeSDK",
            targets: ["StemRuntimeSDK"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            exact: "1.25.4"
        )
    ],
    targets: [
        .binaryTarget(
            name: "StemRuntimeSDK",
            path: "StemRuntimeSDK.xcframework"
        ),
    ]
)
