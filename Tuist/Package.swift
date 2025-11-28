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
        "InfomaniakConcurrency": .framework,
        "InfomaniakCoreCommonUI": .framework,
        "InfomaniakCoreSwiftUI": .framework,
        "InfomaniakCoreUIResources": .framework,
        "InfomaniakNotifications": .framework,
        "InfomaniakCore": .framework,
        "InfomaniakCreateAccount": .framework,
        "InfomaniakDI": .framework,
        "InfomaniakLogin": .framework,
        "InterAppLogin": .framework,
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
        .package(url: "https://github.com/getsentry/sentry-cocoa", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "18.3.0")),
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "24.2.0")),
        .package(url: "https://github.com/Infomaniak/ios-create-account", .upToNextMajor(from: "23.1.0")),
        .package(url: "https://github.com/Infomaniak/ios-dependency-injection", .upToNextMajor(from: "2.0.5")),
        .package(url: "https://github.com/Infomaniak/ios-device-check", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/Infomaniak/ios-features", .upToNextMajor(from: "8.3.0")),
        .package(url: "https://github.com/Infomaniak/ios-login", .upToNextMajor(from: "7.5.0")),
        .package(url: "https://github.com/Infomaniak/ios-notifications", .upToNextMajor(from: "15.1.0")),
        .package(url: "https://github.com/Infomaniak/ios-onboarding", .upToNextMajor(from: "1.4.3")),
        .package(url: "https://github.com/Infomaniak/ios-version-checker", .upToNextMajor(from: "16.0.0")),
        .package(url: "https://github.com/Infomaniak/swift-concurrency", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/matomo-org/matomo-sdk-ios", .upToNextMajor(from: "7.7.0"))
    ]
)
