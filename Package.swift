// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OracleLight",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        // Defines the iOS application product. Xcode 15 and later can open
        // packages with app targets directly. If opening this project in
        // an earlier Xcode, run `swift package generate-xcodeproj`.
        .app(name: "OracleLight", targets: ["OracleLightApp"])
    ],
    dependencies: [
        // Database layer with SQLCipher encryption support via GRDB
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.3.0"),
        // Static analysis tools
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGen", from: "6.6.2"),
        // Testing frameworks
        .package(url: "https://github.com/Quick/Quick", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "12.0.0"),
        .package(url: "https://github.com/xcodeswift/xcvm", from: "1.0.0"),
        // License acknowledgements generator
        .package(url: "https://github.com/mono0926/LicensePlist", from: "3.21.0")
    ],
    targets: [
        // Shared module containing models, services and rule engine used by the
        // main application and the widget/Live Activity extension.
        .target(
            name: "OracleLightShared",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "OracleLightShared"
        ),
        // Main application target. Resources are processed and bundled by SPM.
        .executableTarget(
            name: "OracleLightApp",
            dependencies: [
                "OracleLightShared",
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "OracleLightApp",
            resources: [
                .process("Resources")
            ],
            plugins: [
                // Run SwiftLint and SwiftGen at build time
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
                .plugin(name: "SwiftGenPlugin", package: "SwiftGen")
            ]
        ),
        // Widget / Live Activity extension target. This target must compile as an
        // iOS application extension and depends on the shared module. It does
        // not process resources by default.
        .target(
            name: "OracleLightWidget",
            dependencies: [
                "OracleLightShared"
            ],
            path: "OracleLightWidget"
        ),
        // Unit test target
        .testTarget(
            name: "OracleLightTests",
            dependencies: [
                "OracleLightApp",
                "Quick",
                "Nimble"
            ],
            path: "OracleLightTests"
        ),
        // UI test target using the XCVM tool for snapshot testing
        .testTarget(
            name: "OracleLightUITests",
            dependencies: [
                "OracleLightApp",
                .product(name: "XCVM", package: "xcvm")
            ],
            path: "OracleLightUITests"
        )
    ]
)