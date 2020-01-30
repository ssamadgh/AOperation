// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "AOperation",
    platforms: [.macOS(.v10_10),
                .iOS(.v8),
                .tvOS(.v9),
                .watchOS(.v2)],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "AOperation",
			targets: ["AOperation"]
		)
	],
	dependencies: [],
	targets: [
		.target(name: "AOperation",
				dependencies: [],
				path: "Source"
		)
		]
)
