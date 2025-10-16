// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [
        "Alamofire": .framework,
        "DesignSystem": .framework,
        "DeviceAssociation": .framework,
        "InAppTwoFactorAuthentication": .framework,
        "InfomaniakConcurrency": .staticFramework,
        "InfomaniakCoreCommonUI": .framework,
        "InfomaniakCoreSwiftUI": .framework,
        "InfomaniakCoreUIResources": .framework,
        "InfomaniakCore": .framework,
        "InfomaniakDI": .framework,
        "InfomaniakLogin": .framework,
        "InterAppLogin": .framework,
        "Lottie": .framework,
        "NukeUI": .framework,
        "Nuke": .framework,
        "VersionChecker": .framework,
        "_LottieStub": .framework
    ]
)
#endif

let package = Package(
    name: "Euria",
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm", .upToNextMajor(from: "4.5.1")),
        .package(url: "https://github.com/getsentry/sentry-cocoa", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "18.1.0")),
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "24.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-dependency-injection", .upToNextMajor(from: "2.0.5")),
        .package(url: "https://github.com/Infomaniak/ios-device-check", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/Infomaniak/ios-features", .upToNextMajor(from: "8.1.0")),
        .package(url: "https://github.com/Infomaniak/ios-login", .upToNextMajor(from: "7.3.0")),
        .package(url: "https://github.com/Infomaniak/ios-onboarding", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/Infomaniak/ios-version-checker", .upToNextMajor(from: "16.0.0")),
        .package(url: "https://github.com/Infomaniak/swift-concurrency", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/matomo-org/matomo-sdk-ios", .upToNextMajor(from: "7.7.0"))
    ]
)
