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
            url: "https://github.com/vkrychun/stem-runtime-swift/releases/download/v1.2.0/StemRuntimeSDK.xcframework.zip",
            checksum: "27570dab7ac5c3c6ac1c804ac8a151dab61e29adf02b4054c9c0669ee470391d"
        ),
    ]
)
