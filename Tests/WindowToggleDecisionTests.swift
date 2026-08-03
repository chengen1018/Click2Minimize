import Foundation

func expect(_ actual: String, _ expected: String, _ name: String) {
    guard actual == expected else {
        fputs("FAIL: \(name): expected \(expected), got \(actual)\n", stderr)
        exit(1)
    }
}

func expect(_ actual: [String], _ expected: [String], _ name: String) {
    guard actual == expected else {
        fputs("FAIL: \(name): expected \(expected), got \(actual)\n", stderr)
        exit(1)
    }
}

@main
struct WindowToggleDecisionTests {
    static func main() {
        expect(windowAction(visible: 2, minimized: 1), "minimize", "visible windows minimize")
        expect(windowAction(visible: 0, minimized: 3), "restore", "all minimized windows restore")
        expect(windowAction(visible: 0, minimized: 0), "pass", "no windows pass through")
        expect(
            steamRelatedBundleIdentifiers(bundleIdentifier: "com.valvesoftware.steam"),
            ["com.valvesoftware.steam", "com.valvesoftware.steam.helper"],
            "Steam includes its helper process"
        )
        expect(
            steamRelatedBundleIdentifiers(bundleIdentifier: "com.apple.finder"),
            ["com.apple.finder"],
            "non-Steam apps keep one process"
        )
        print("PASS: WindowToggleDecisionTests")
    }
}
