import Foundation

func windowAction(visible: Int, minimized: Int) -> String {
    if visible > 0 { return "minimize" }
    if minimized > 0 { return "restore" }
    return "pass"
}

/// Steam's UI is split between the main app and its accessibility-visible helper.
/// Keep this pure so the process-grouping rule can be tested without launching UI.
func steamRelatedBundleIdentifiers(bundleIdentifier: String?) -> [String] {
    guard bundleIdentifier == "com.valvesoftware.steam" else {
        return bundleIdentifier.map { [$0] } ?? []
    }
    return ["com.valvesoftware.steam", "com.valvesoftware.steam.helper"]
}
