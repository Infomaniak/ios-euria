import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let preloadingView = Feature(name: "PreloadingView", additionalDependencies: [
    TargetDependency.external(name: "DesignSystem"),
    TargetDependency.external(name: "InfomaniakCoreCommonUI"),
    TargetDependency.external(name: "InfomaniakCoreSwiftUI"),
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "InfomaniakDI")
])

let onboardingView = Feature(name: "OnboardingView", additionalDependencies: [
    TargetDependency.external(name: "InfomaniakConcurrency"),
    TargetDependency.external(name: "InfomaniakCore"),
    TargetDependency.external(name: "InfomaniakDeviceCheck"),
    TargetDependency.external(name: "InfomaniakDI"),
    TargetDependency.external(name: "InfomaniakLogin"),
    TargetDependency.external(name: "InfomaniakOnboarding"),
    TargetDependency.external(name: "InterAppLogin"),
    TargetDependency.external(name: "Lottie")
])

let mainView = Feature(
    name: "MainView",
    dependencies: [onboardingView],
    additionalDependencies: [
        TargetDependency.external(name: "InfomaniakCoreUIResources"),
        TargetDependency.external(name: "InfomaniakNotifications"),
        TargetDependency.external(name: "VersionChecker")
    ]
)

let rootView = Feature(
    name: "RootView",
    dependencies: [mainView, preloadingView, onboardingView, TargetDependency.external(name: "VersionChecker")]
)

let mainiOSAppFeatures = [
    rootView,
    mainView,
    preloadingView,
    onboardingView
]

let project = Project(
    name: "Euria",
    targets: mainiOSAppFeatures.asTargets + [
        .target(
            name: "Euria",
            destinations: .iOS,
            product: .app,
            bundleId: Constants.baseIdentifier,
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: "Euria/Resources/Info.plist",
            sources: [
                "Euria/Sources/**",
                "EuriaWidget/QuickActionsControlWidget/SharedIntent/**"
            ],
            resources: [
                "Euria/Resources/LaunchScreen.storyboard",
                "Euria/Resources/Assets.xcassets", // Needed for AppIcon and LaunchScreen
                "Euria/Resources/PrivacyInfo.xcprivacy",
                "Euria/Resources/Localizable/**/*.strings",
                "Euria/Resources/AppIcon.icon/**"
            ],
            entitlements: "Euria/Resources/Euria.entitlements",
            scripts: [
                Constants.swiftlintScript,
                Constants.stripSymbolsScript
            ],
            dependencies: [
                .target(name: "EuriaCore"),
                .target(name: "EuriaCoreUI"),
                .target(name: "EuriaWidget"),
				.target(name: "EuriaShareExtension"),
                .external(name: "InfomaniakCoreCommonUI"),
                .external(name: "InfomaniakDI"),
                .external(name: "InfomaniakNotifications"),
                rootView.asDependency
            ],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).", isEnabled: true)
            ]
        ),
        .target(name: "EuriaCore",
                destinations: Constants.destinations,
                product: Constants.productTypeBasedOnEnv,
                bundleId: "\(Constants.baseIdentifier).core",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "EuriaCore/**",
                dependencies: [
                    .target(name: "EuriaResources"),
                    .external(name: "DesignSystem"),
                    .external(name: "DeviceAssociation"),
                    .external(name: "InAppTwoFactorAuthentication"),
                    .external(name: "InfomaniakConcurrency"),
                    .external(name: "InfomaniakCoreCommonUI"),
                    .external(name: "InfomaniakCoreSwiftUI"),
                    .external(name: "InfomaniakCoreUIKit"),
                    .external(name: "InfomaniakCreateAccount"),
                    .external(name: "InfomaniakLogin"),
                    .external(name: "InfomaniakNotifications"),
                    .external(name: "InterAppLogin"),
                    .external(name: "Sentry-Dynamic")
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "EuriaCoreUI",
                destinations: Constants.destinations,
                product: Constants.productTypeBasedOnEnv,
                bundleId: "\(Constants.baseIdentifier).coreui",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                sources: "EuriaCoreUI/**",
                dependencies: [
                    .target(name: "EuriaCore"),
                    .external(name: "InfomaniakCoreUIResources")
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(name: "EuriaResources",
                destinations: Constants.destinations,
                product: Constants.productTypeBasedOnEnv,
                bundleId: "\(Constants.baseIdentifier).resources",
                deploymentTargets: Constants.deploymentTarget,
                infoPlist: .default,
                resources: [
                    "EuriaResources/**/*.xcassets",
                    "EuriaResources/**/*.strings",
                    "EuriaResources/**/*.stringsdict",
                    "EuriaResources/**/*.json",
                    "EuriaResources/**/*.lottie"
                ],
                settings: .settings(base: Constants.baseSettings)),
        .target(
            name: "EuriaWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "\(Constants.baseIdentifier).EuriaWidget",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: "EuriaWidget/Resources/Info.plist",
            sources: "EuriaWidget/**",
            resources: [
                "EuriaWidget/Resources/Assets.xcassets"
            ],
            dependencies: [
                .target(name: "EuriaCore"),
                .target(name: "EuriaCoreUI"),
                .external(name: "DesignSystem"),
                .external(name: "InfomaniakCoreSwiftUI")
            ],
            settings: .settings(base: Constants.baseSettings)
        )),
	.target(
            name: "EuriaShareExtension",
            destinations: Set<Destination>([.iPhone, .iPad]),
            product: .appExtension,
            bundleId: "\(Constants.baseIdentifier).ShareExtension",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "CFBundleName": "$(PRODUCT_NAME)",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "AppIdentifierPrefix": "$(AppIdentifierPrefix)",
                "CFBundleDisplayName": "$(PRODUCT_NAME)",
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.share-services",
                    "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).ShareViewController",
                    "NSExtensionAttributes": [
                        "NSExtensionActivationRule": "TRUEPREDICATE"
                    ]
                ]
            ]),
            sources: "EuriaShareExtension/Sources/**",
            resources: [],
            entitlements: "EuriaShareExtension/Resources/Euria.entitlements",
            dependencies: [
                .target(name: "EuriaCore"),
                .target(name: "EuriaCoreUI"),
            ],
            settings: .settings(base: Constants.baseSettings),
            environmentVariables: [
                "hostname": .environmentVariable(value: "\(ProcessInfo.processInfo.hostName).", isEnabled: true)
            ]
        )
    ],
    fileHeaderTemplate: .file("file-header-template.txt")
)
