// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Elements",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "Elements",
            targets: ["Bootstrap"]
        ),
    ],
    targets: [
        .target(
            name: "Bootstrap",
            dependencies: ["Framework"],
            path: "Sources"
        ),
        .binaryTarget(
            name: "Framework",
            url: "https://github.com/whopio/elements-swift/releases/download/0.1.3/Elements.xcframework.zip",
            checksum: "1607735b6213406786b7da4d276ae9e69d25c165fdaad0975b5c179095e19073"
        ),
    ],
    swiftLanguageModes: [.v5]
)
