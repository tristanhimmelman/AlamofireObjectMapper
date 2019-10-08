// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AlamofireObjectMapper",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "AlamofireObjectMapper", targets: ["AlamofireObjectMapper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/NeoChow/Alamofire", .branch("tweak-package-file")),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper", .revision("feb763a93755b5b576e09a9db2cb8d380fd65ba2")),
    ],
    targets: [
        .target(name: "AlamofireObjectMapper", dependencies: ["Alamofire", "ObjectMapper"], path: "AlamofireObjectMapper"),
    ],
    swiftLanguageVersions: [.v5, .v4]
)
