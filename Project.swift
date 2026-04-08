import ProjectDescription

let appName = "__PROJECT_NAME__"
let testTargetName = "__TEST_SCHEME__"
let bundleId = "__BUNDLE_ID__"

let project = Project(
    name: appName,
    options: .options(
        disableSynthesizedResourceAccessors: true
    ),
    targets: [
        .target(
            name: appName,
            destinations: [.iPhone, .iPad, .macCatalyst],
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "App/Sources",
                "App/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: testTargetName,
            destinations: [.iPhone, .iPad, .macCatalyst],
            product: .unitTests,
            bundleId: "\(bundleId).tests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: [
                "App/Tests"
            ],
            dependencies: [.target(name: appName)]
        ),
    ]
)
