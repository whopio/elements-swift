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
            url: "https://github.com/whopio/elements-swift/releases/download/0.1.2/Elements.xcframework.zip",
            checksum: "bfb414f461d002625ca9fb70e129692ef8ac72655080ee0fba9028789e182eb7"
        ),
    ],
    swiftLanguageModes: [.v5]
)
