# Native Window Toggle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the local app into a Dock toggle: minimize visible windows, restore all minimized windows, and safely handle Finder.

**Architecture:** A pure decision engine chooses one action from counts of eligible visible and minimized windows. An Accessibility gateway obtains those counts and changes only the corresponding windows. The existing Dock event monitor invokes the controller and lets macOS handle inactive, full-screen, and no-window states.

**Tech Stack:** Swift 5, macOS 13+, AppKit, Accessibility API, XCTest, Xcode 26.6.

## Global Constraints

- Build arm64 only; add no dependencies, private APIs, network update code, or screen-recording permission.
- With visible windows, minimize all visible windows; with zero visible and one or more minimized windows, restore all minimized windows, including manually minimized windows.
- Finder accepts only `AXWindow` with `AXStandardWindow` subrole and a readable minimization attribute.
- A failed Accessibility operation always passes the original Dock click through.

---

### Task 1: Decision engine and red-green tests

**Files:**
- Create: `Click2Minimize/WindowToggleDecision.swift`
- Create: `Click2MinimizeTests/WindowToggleDecisionTests.swift`
- Modify: `Click2Minimize.xcodeproj/project.pbxproj`

**Interfaces:**

```swift
enum WindowToggleAction: Equatable { case minimizeVisible, restoreMinimized, passThrough }
struct WindowToggleSnapshot { let visibleEligibleCount: Int; let minimizedEligibleCount: Int }
enum WindowToggleDecider { static func action(for snapshot: WindowToggleSnapshot) -> WindowToggleAction }
```

- [ ] Add an XCTest target named `Click2MinimizeTests`, reference `WindowToggleDecision.swift` from the app target, and use `@testable import Click2Minimize` in the test target.
- [ ] Write the failing tests:

```swift
func testVisibleWindowsChooseMinimize() {
    XCTAssertEqual(WindowToggleDecider.action(for: .init(visibleEligibleCount: 2, minimizedEligibleCount: 1)), .minimizeVisible)
}
func testAllMinimizedWindowsChooseRestore() {
    XCTAssertEqual(WindowToggleDecider.action(for: .init(visibleEligibleCount: 0, minimizedEligibleCount: 3)), .restoreMinimized)
}
func testNoEligibleWindowsPassThrough() {
    XCTAssertEqual(WindowToggleDecider.action(for: .init(visibleEligibleCount: 0, minimizedEligibleCount: 0)), .passThrough)
}
```

- [ ] Run the tests and verify they fail because the production types are absent:

```bash
xcodebuild test -project Click2Minimize.xcodeproj -scheme Click2Minimize -destination 'platform=macOS,arch=arm64' -only-testing:Click2MinimizeTests/WindowToggleDecisionTests
```

- [ ] Implement the three public types above with `visibleEligibleCount > 0` taking precedence, then `minimizedEligibleCount > 0`, then pass-through.
- [ ] Re-run the focused test and verify all three tests pass.

### Task 2: Accessibility classification and window actions

**Files:**
- Create: `Click2Minimize/AccessibilityWindowGateway.swift`
- Create: `Click2MinimizeTests/WindowEligibilityTests.swift`
- Modify: `Click2Minimize.xcodeproj/project.pbxproj`

**Interfaces:**

```swift
struct WindowSnapshotResult { let snapshot: WindowToggleSnapshot; let visible: [AXUIElement]; let minimized: [AXUIElement] }
final class AccessibilityWindowGateway {
    func snapshot(for app: NSRunningApplication) -> WindowSnapshotResult?
    func apply(_ action: WindowToggleAction, to result: WindowSnapshotResult) -> Bool
}
enum WindowEligibility { static func isEligible(bundleIdentifier: String, role: String?, subrole: String?, supportsMinimize: Bool) -> Bool }
```

- [ ] Write failing eligibility tests for a regular minimizable window, a Finder `AXWindow` / `AXStandardWindow`, and a Finder desktop/unknown subrole.
- [ ] Run only `WindowEligibilityTests` and verify it fails because `WindowEligibility` is absent.
- [ ] Implement the eligibility helper; query `kAXWindowsAttribute`, then partition eligible windows by the readable boolean `kAXMinimizedAttribute`.
- [ ] Implement `apply`: set `kAXMinimizedAttribute` to `true` only for `.minimizeVisible`, and `false` only for `.restoreMinimized`; return true only if one or more writes succeed.
- [ ] Re-run all tests:

```bash
xcodebuild test -project Click2Minimize.xcodeproj -scheme Click2Minimize -destination 'platform=macOS,arch=arm64'
```

### Task 3: Replace the one-way click handler

**Files:**
- Create: `Click2Minimize/WindowToggleController.swift`
- Create: `Click2MinimizeTests/WindowToggleControllerTests.swift`
- Modify: `Click2Minimize/AppDelegate.swift:188-253`
- Modify: `Click2Minimize.xcodeproj/project.pbxproj`

**Interfaces:**

```swift
final class WindowToggleController {
    init(gateway: AccessibilityWindowGateway = .init())
    func toggleWindows(for app: NSRunningApplication) -> Bool
}
```

- [ ] Write a failing controller test using a fake gateway: a visible+minimized snapshot calls `.minimizeVisible`, all-minimized calls `.restoreMinimized`, and an empty Finder snapshot invokes no action.
- [ ] Run only `WindowToggleControllerTests` and verify the missing-controller failure.
- [ ] Implement the controller as snapshot → decision → `apply`; no stored minimization session is used.
- [ ] In `AppDelegate.eventTapCallback`, keep the existing inactive/hidden and full-screen guards. Replace `minimizeAppWindows(for:)` with `WindowToggleController.toggleWindows(for:)`; consume the event only for a successful action.
- [ ] Delete `checkForUpdates()` from app initialization and remove all release-fetch, DMG-download, replacement-install, and relaunch methods. Retain AppleScript only for obtaining Dock rectangles.
- [ ] Run the complete test suite and an unsigned Release build:

```bash
xcodebuild test -project Click2Minimize.xcodeproj -scheme Click2Minimize -destination 'platform=macOS,arch=arm64'
xcodebuild build -project Click2Minimize.xcodeproj -scheme Click2Minimize -configuration Release -destination 'platform=macOS,arch=arm64' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

### Task 4: Local install and acceptance checks

**Files:**
- Modify: `/Applications/Click2Minimize.app` only after successful build verification.

- [ ] Ad-hoc sign and verify the Release app:

```bash
codesign --force --deep --sign - build/Build/Products/Release/Click2Minimize.app
codesign --verify --deep --strict --verbose=2 build/Build/Products/Release/Click2Minimize.app
```

- [ ] Quit the old local Click2Minimize, replace it with the verified build, and launch the full application path.
- [ ] Manually verify: Finder Recents minimizes then restores the same window; Chrome A manually minimized plus B/C visible restores A/B/C after two toggles; Finder with no regular windows is passed to macOS; inactive-app clicks only activate the app.
- [ ] Do not commit or publish without explicit user authorization.
