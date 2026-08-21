import ProjectDescription

let project = Project(
    name: "EstacioneAqui",
    organizationName: "teloeken",
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "6N2JAUH25Y",
            "SWIFT_VERSION": "5.0",
            "MARKETING_VERSION": "1.0",
            "CURRENT_PROJECT_VERSION": "1",
        ]
    ),
    targets: [
        .target(
            name: "EstacioneAqui",
            destinations: [.iPhone, .iPad, .appleVision],
            product: .app,
            bundleId: "teloeken.EstacioneAqui",
            deploymentTargets: .iOS("26.5"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "NSSupportsLiveActivities": true,
                "CFBundleURLTypes": [
                    [
                        "CFBundleURLName": "teloeken.EstacioneAqui.session",
                        "CFBundleURLSchemes": ["estacioneaqui"],
                    ],
                ],
                "CFBundleDevelopmentRegion": "en",
                "CFBundleLocalizations": ["en", "pt-BR", "es"],
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight",
                ],
                "UISupportedInterfaceOrientations~ipad": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationPortraitUpsideDown",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight",
                ],
                "NSAppTransportSecurity": [
                    "NSAllowsLocalNetworking": true,
                ],
                "NSLocationWhenInUseUsageDescription":
                    "We use your location to find the blue zone you're in and start parking.",
            ]),
            sources: ["EstacioneAqui/**/*.swift"],
            resources: [
                "EstacioneAqui/Assets.xcassets",
                "EstacioneAqui/Resources/**",
            ],
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "Pulse"),
                .external(name: "PulseUI"),
                .target(name: "EstacioneAquiWidgets"),
            ],
            settings: .settings(base: [
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
            ])
        ),
        .target(
            name: "EstacioneAquiWidgets",
            destinations: [.iPhone, .iPad],
            product: .appExtension,
            bundleId: "teloeken.EstacioneAqui.Widgets",
            deploymentTargets: .iOS("26.5"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "EstacioneAqui",
                "CFBundleDevelopmentRegion": "en",
                "CFBundleLocalizations": ["en", "pt-BR", "es"],
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                ],
            ]),
            sources: [
                "EstacioneAquiWidgets/**/*.swift",
                "EstacioneAqui/Core/LiveActivity/ParkingActivityAttributes.swift",
                "EstacioneAqui/Core/LiveActivity/ParkingDeepLink.swift",
            ],
            resources: ["EstacioneAquiWidgets/Resources/**"]
        ),
        .target(
            name: "EstacioneAquiTests",
            destinations: [.iPhone, .iPad, .appleVision],
            product: .unitTests,
            bundleId: "teloeken.EstacioneAquiTests",
            deploymentTargets: .iOS("26.5"),
            infoPlist: .default,
            sources: ["EstacioneAquiTests/**/*.swift"],
            dependencies: [
                .target(name: "EstacioneAqui"),
            ]
        ),
        .target(
            name: "EstacioneAquiUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "teloeken.EstacioneAquiUITests",
            deploymentTargets: .iOS("26.5"),
            infoPlist: .default,
            sources: ["EstacioneAquiUITests/**/*.swift"],
            dependencies: [
                .target(name: "EstacioneAqui"),
            ]
        ),
    ]
)
