// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MacroPlayground",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "MacroPlayground",
            targets: ["MacroPlayground"]),
        .executable(
            name: "MacroPlaygroundClient",
            targets: ["MacroPlaygroundClient"]),
    ],
    dependencies: [
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git",
                 from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-07-10-a"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MacroPlaygroundMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "MacroPlayground",
            dependencies: [
                "MacroPlaygroundMacros",
            ]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "MacroPlaygroundClient",
            dependencies: [
                "MacroPlayground",
            ]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MacroPlaygroundTests",
            dependencies: [
                "MacroPlaygroundMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]),
    ]
)
