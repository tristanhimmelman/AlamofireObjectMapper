// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let alamofireVersionStr = "5.0.0-rc.2"
let objectMapperVersionStr = "3.5.1"

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
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact(Version(alamofireVersionStr)!)),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .exact(Version(objectMapperVersionStr)!)),
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
