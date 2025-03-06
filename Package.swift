// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Fuzzywuzzy_swift",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Fuzzywuzzy_swift",
            targets: ["Fuzzywuzzy_swift"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Fuzzywuzzy_swift",
            path: "Fuzzywuzzy_swift",
            exclude: ["Info.plist"],
            sources: ["."],
            publicHeadersPath: "."
        )
    ]
)
