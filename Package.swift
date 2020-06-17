// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "AlamofireObjectMapper",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3),
        .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "AlamofireObjectMapper",
            targets: ["AlamofireObjectMapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0-rc.2")),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.2.0")),
    ],
    targets: [
        .target(
            name: "AlamofireObjectMapper",
            dependencies: [
                "Alamofire",
                "ObjectMapper"
            ],
            path: "AlamofireObjectMapper",
            exclude: [
                "AlamofireObjectMapperTest",
                "Carthage"
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
let version = Version(6, 2, 0)
