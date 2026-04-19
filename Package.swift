// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuCalendar",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "MenuCalendarCore",
            targets: ["MenuCalendarCore"]
        ),
        .executable(
            name: "MenuCalendar",
            targets: ["MenuCalendar"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.10.0"),
    ],
    targets: [
        .target(
            name: "MenuCalendarCore",
            path: "CoreSources"
        ),
        .target(
            name: "MenuCalendarUI",
            dependencies: ["MenuCalendarCore"],
            path: "UI"
        ),
        .executableTarget(
            name: "MenuCalendar",
            dependencies: ["MenuCalendarCore", "MenuCalendarUI"],
            path: "App"
        ),
        .testTarget(
            name: "MenuCalendarTests",
            dependencies: [
                "MenuCalendarCore",
                "MenuCalendarUI",
                .product(name: "ViewInspector", package: "ViewInspector"),
            ],
            path: "Tests"
        ),
    ]
)
