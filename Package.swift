// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LayoutFixer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "LayoutFixer",
            path: "Sources/LayoutFixer",
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("AppKit"),
                .linkedFramework("ServiceManagement"),
            ]
        )
    ]
)
