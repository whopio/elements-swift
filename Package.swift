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
            url: "https://github.com/whopio/elements-swift/releases/download/0.1.1/Elements.xcframework.zip",
            checksum: "df32aaf808bd1875639fe2b161e81a74fb8bd3dd9b783f5483b05ebc040c7d37"
        ),
    ],
    swiftLanguageModes: [.v5]
)
