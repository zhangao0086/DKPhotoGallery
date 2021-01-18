// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DKPhotoGallery",
    defaultLocalization: "en",
    products: [
        .library(
            name: "DKPhotoGallery",
            targets: ["DKPhotoGallery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kirualex/SwiftyGif.git", from: "5.3.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.10.0"),
    ],
    targets: [
        .target(
            name: "DKPhotoGallery",
            dependencies: ["SwiftyGif", "SDWebImage"],
            path: "DKPhotoGallery"),
    ]
)
