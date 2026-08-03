import Foundation

func expect(_ actual: String, _ expected: String, _ name: String) {
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
        print("PASS: WindowToggleDecisionTests")
    }
}
