// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Alamofire": .framework,
        "Pulse": .framework,
        "PulseUI": .framework,
    ]
)
#endif

let package = Package(
    name: "EstacioneAqui",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.2"),
        .package(url: "https://github.com/kean/Pulse", from: "5.1.4"),
    ]
)
