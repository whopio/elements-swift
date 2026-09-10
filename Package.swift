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
            url: "https://github.com/whopio/elements-swift/releases/download/0.1.0/Elements.xcframework.zip",
            checksum: "5392b3f2dfd2874808f9a3d7a847f3943b7946e3bb64f524dd395ec7e44f0181"
        ),
    ],
    swiftLanguageModes: [.v5]
)
