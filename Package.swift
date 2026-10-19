// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Extension",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Extension", targets: ["Extension"])
    ],
    dependencies: [
        .package(url: "https://github.com/foxterm/libetos.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Extension",
            dependencies: ["libetos"]
        )
    ]
)
