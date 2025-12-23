// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "lewens",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "lewens",
            targets: ["lewens"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/openid/AppAuth-iOS.git", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "lewens",
            dependencies: [
                .product(name: "AppAuth", package: "AppAuth-iOS")
            ]
        ),
    ]
)
