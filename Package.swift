// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlamofireObjectMapper",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AlamofireObjectMapper",
            targets: [
                "AlamofireObjectMapper"
            ])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.3"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper", from: "4.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AlamofireObjectMapper",
            dependencies: ["Alamofire", "ObjectMapper"],
            path: "Sources/AlamofireObjectMapper",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "AlamofireObjectMapperTests",
            dependencies: ["AlamofireObjectMapper"],
            path: "Tests/AlamofireObjectMapperTests",
            exclude: ["Info.plist"])
    ]
)
