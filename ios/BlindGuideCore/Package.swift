// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BlindGuideCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14), // lets `swift test` run on the Mac host
    ],
    products: [
        .library(name: "BlindGuideCore", targets: ["BlindGuideCore"]),
    ],
    targets: [
        .target(name: "BlindGuideCore"),
        .testTarget(name: "BlindGuideCoreTests", dependencies: ["BlindGuideCore"]),
    ]
)
