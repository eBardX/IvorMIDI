// swift-tools-version: 6.2

// © 2025–2026 John Gary Pusey (see LICENSE.md)

import PackageDescription

let swiftSettings: [SwiftSetting] = [.defaultIsolation(nil),
                                     .enableUpcomingFeature("ExistentialAny"),
                                     .enableUpcomingFeature("ImmutableWeakCaptures"),
                                     .enableUpcomingFeature("InferIsolatedConformances"),
                                     .enableUpcomingFeature("InternalImportsByDefault"),
                                     .enableUpcomingFeature("MemberImportVisibility"),
                                     .enableUpcomingFeature("NonisolatedNonsendingByDefault")]

let package = Package(name: "IvorMIDI",
                      platforms: [.iOS(.v18),
                                  .macOS(.v15)],
                      products: [.library(name: "IvorMIDI",
                                          targets: ["IvorMIDI"])],
                      dependencies: [.package(url: "https://github.com/eBardX/XestiTools.git",
                                              .upToNextMajor(from: "7.5.0"))],
                      targets: [.target(name: "IvorMIDI",
                                        dependencies: [.product(name: "XestiTools",
                                                                package: "XestiTools")],
                                        swiftSettings: swiftSettings),
                                .testTarget(name: "IvorMIDITests",
                                            dependencies: [.target(name: "IvorMIDI")],
                                            resources: [.process("Fixtures")],
                                            swiftSettings: swiftSettings)],
                      swiftLanguageModes: [.v6])
