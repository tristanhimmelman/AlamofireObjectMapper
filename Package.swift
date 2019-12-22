// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AlamofireObjectMapper",
    products: [
        .library(
            name: "AlamofireObjectMapper",
            targets: ["AlamofireObjectMapper"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: Version(4, 9, 0)),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", from: Version(3, 5, 0))
    ],
    targets: [
        .target(name: "AlamofireObjectMapper", path: "AlamofireObjectMapper")
    ]
)
