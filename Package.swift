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
        .package(url: "https://github.com/Alamofire/Alamofire.git",from: "5.0.0-rc.3"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", from: "3.5.0")
    ],
    targets: [
        .target(
            name: "AlamofireObjectMapper",
            dependencies: [
            "Alamofire",
            "ObjectMapper"
            ],
            path: "AlamofireObjectMapper")
    ]
)
