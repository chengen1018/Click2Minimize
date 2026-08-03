import Foundation

func windowAction(visible: Int, minimized: Int) -> String {
    if visible > 0 { return "minimize" }
    if minimized > 0 { return "restore" }
    return "pass"
}
