<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-TW.md">繁體中文</a>
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/hero-banner-dark.svg" />
    <img src="assets/hero-banner.svg" alt="Click2Minimize" width="100%" />
  </picture>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-1A1A1A?style=for-the-badge&logo=apple&logoColor=CCFF00" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-5-1A1A1A?style=for-the-badge&logo=swift&logoColor=CCFF00" alt="Swift 5" />
  <img src="https://img.shields.io/badge/Xcode-16-1A1A1A?style=for-the-badge&logo=xcode&logoColor=CCFF00" alt="Xcode 16" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/LICENSE-POLYFORM_NC-1A1A1A?style=for-the-badge&labelColor=1A1A1A&color=CCFF00" alt="PolyForm Noncommercial" /></a>
</p>

<p align="center">
  <em><strong>Click an app's dock icon to minimize its windows.</strong> macOS doesn't ship with this behaviour by default — Click2Minimize is a ~570-LOC Swift menu-bar utility that adds it. Accessory app, no window, no telemetry. Lives in the menu bar, runs an event tap, talks to the dock via Accessibility + AppleScript. Free to use personally — not for commercial reuse (see <a href="LICENSE">LICENSE</a>).</em>
</p>

---

### `/// PROJECT ORIGIN & ATTRIBUTION`

This repository is a derivative work based on [Click2Minimize](https://github.com/hatimhtm/Click2Minimize) by Hatim El Hassak. The original project and its source code remain subject to the [PolyForm Noncommercial 1.0.0 license](LICENSE).

The changes in this repository are maintained by **Chengen** and currently focus on:

- visible-window-first Dock toggling;
- restoring all minimized windows for an application, including windows minimized manually before the toggle;
- safer Finder handling that only acts on standard Finder windows;
- local decision tests.

This project is for personal, educational, research, and other permitted noncommercial use. It is not an independent from-scratch implementation of Click2Minimize.

### `/// WHAT IT DOES`

When you click the dock icon of an already-focused app, macOS does nothing — the click just re-activates an app that's already active. Click2Minimize swaps that no-op for the obvious behaviour: minimize the app's windows. Click again to bring them back. Like the Windows taskbar, but on macOS.

- Click a **focused** app's dock icon → windows minimize.
- Click the focused app's icon when all its eligible windows are minimized → all eligible windows restore.
- Click an **unfocused** app's icon → default macOS behaviour (focus, raise).
- Click **Launchpad / Trash / Downloads** → default behaviour (these have no windows to minimize).
- App is **fullscreen** → pass-through (no minimize, you didn't mean it).

---

### `/// HOW IT WORKS`

```
                                                 ┌─────────────────────┐
                                                 │ NSWorkspace notifs  │
                                                 │  (launch · activate │
                                                 │   · space change)   │
                                                 └──────────┬──────────┘
                                                            │ debounced 300ms
                                                            ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐
│ CGEvent tap     │───▶│ hit-test mouse  │    │ AppleScript query Dock  │
│ (left mousedown)│    │ vs dock rects   │    │ → rects + app names     │
└─────────────────┘    └─────────────────┘    └─────────────────────────┘
                                │
                                ▼
              ┌─────────────────────────────────────────┐
              │ AXUIElement → set kAXMinimized = true   │
              │ on every visible window of the app      │
              └─────────────────────────────────────────┘
```

- **Event tap** runs at `cghidEventTap` / `tailAppendEventTap`, captures left mouse-down only.
- **Dock rects** are cached and refreshed on a trailing-edge 300ms debounce — bursts of `didLaunch / didActivate / activeSpaceDidChange` collapse into a single AppleScript call.
- **Window minimization** goes through `AXUIElementSetAttributeValue(kAXMinimizedAttribute)` — the proper accessibility API, not key-event simulation.
- **Fullscreen detection** reads `AXFullScreen` on the frontmost app's windows (rewritten in 1.5 — the old check was inspecting Click2Minimize's own windows).

---

### `/// HIGHLIGHTS`

| | |
|---|---|
| **No window** | `LSUIElement`-style accessory app; lives only in the menu bar |
| **No telemetry** | The current startup path makes no network calls |
| **No background daemon** | Just one process, registers a `CGEvent` tap via Accessibility |
| **Modern Swift logging** | `os.Logger` with subsystem + privacy modifiers; no `print()` spam in Release |
| **Opt-in launch-at-login** | SwiftUI toggle wires `SMAppService.mainApp` register/unregister; was unconditional before 1.5 |
| **Fallback dock scan** | If `AXUIElement` can't read the dock list, an AppleScript fallback recovers app names from `System Events` |
| **Universal binary** | `build_dmg.sh` requests arm64 + x86_64 and creates an ad-hoc signed DMG |
| **Source-available** | PolyForm Noncommercial 1.0.0 — read it, learn from it, run it personally, don't include it in commercial products |

---

### `/// 2.1 — WHAT CHANGED FROM 2.0`

- **Fixed**: `isActiveAppFullscreen()` was inspecting Click2Minimize's own `NSWindow`s — always returned false. Rewritten to read `AXFullScreen` on the frontmost app via Accessibility.
- **Fixed**: dock-item ignore-list was `"Launchpad||Trash||Downloads".contains(name)` — substring match, would catch "TrashCan" or any app with "Trash" in the name. Replaced with proper `Set` membership.
- **Fixed**: dock-update debounce was firing every event and only suppressing later ones inside the 0.5s window — it never actually coalesced bursts. Rewritten with `DispatchWorkItem` trailing-edge debounce at 300ms.
- **Improved**: all `print()` calls migrated to `os.Logger` with privacy modifiers. Release builds no longer write to stdout.
- **Improved**: launch-at-login is now an opt-in toggle in Settings instead of unconditional. Existing installs that were auto-registered stay registered until toggled off.
- **Improved**: settings sheet redesigned — launch-at-login row, cleaner spacing, footnote anchored.
- **Improved**: deprecated `NSWorkspace.launchApplication(_:)` swapped for `openApplication(at:configuration:completionHandler:)`.
- **Bumped**: marketing version → 2.1 to align the in-app version with the GitHub release tag (was 1.4 in-plist while the latest release was already tagged v2.0).

---

### `/// INSTALL`

This repository does not currently publish its own Release or downloadable DMG. Build the app locally by following [BUILD FROM SOURCE](#-build-from-source), or open the Xcode project and use **Product → Build**.

After building, launch `Click2Minimize.app` and grant **Accessibility** permission in System Settings → Privacy & Security → Accessibility. If you use Catalyst / Electron apps and want the fallback to work cleanly, also grant **Automation** when macOS asks.

Locally built releases are ad-hoc signed, so the first launch may require right-click → **Open** to get past Gatekeeper.

---

### `/// BUILD FROM SOURCE`

```bash
git clone https://github.com/chengen1018/Click2Minimize.git
cd Click2Minimize

# Open the project in Xcode
open Click2Minimize.xcodeproj

# Release build into ./build
xcodebuild -project Click2Minimize.xcodeproj -scheme Click2Minimize \
  -configuration Release -derivedDataPath build

# Or build the full DMG in ./dist
./build_dmg.sh
```

Requires Xcode 15+. Targets macOS 13.0+.

---

### `/// LICENSE`

[PolyForm Noncommercial 1.0.0](LICENSE). In plain English:

- **Allowed**: reading, learning, personal use, hobby use, non-profit / educational / research use, forking to improve, distributing your fork under the same license.
- **Not allowed**: shipping it inside a paid product, selling support for it, embedding it in commercial software, any commercial use.

Read [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md) before redistributing or publishing changes.

---
