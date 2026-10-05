<p align="center"><strong>English</strong> · <a href="README.zh-TW.md">繁體中文</a></p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/hero-banner-dark.svg">
    <img src="assets/hero-banner.svg" alt="Click2Minimize: click the active app's Dock icon to minimize or restore its windows" width="100%">
  </picture>
</p>

<p align="center"><strong>One Dock click. All your windows, out of the way.</strong><br>
A small macOS menu bar app that makes the active app's Dock icon a minimize/restore toggle.</p>

<p align="center">macOS 13+ · Swift 5 · Build with Xcode 15+ · <a href="LICENSE">PolyForm Noncommercial 1.0.0</a></p>

> **About this fork:** This is a derivative of [Hatim El Hassak's Click2Minimize](https://github.com/hatimhtm/Click2Minimize), maintained by Chengen. See [what changed](#what-this-fork-changes), [NOTICE.md](NOTICE.md), and the [license](LICENSE).

## What happens when you click?

| Dock click | Result |
| --- | --- |
| Active app with visible windows | Minimize its eligible visible windows. |
| Active app with no visible windows, but minimized windows | Restore its eligible minimized windows, including ones minimized by hand. |
| Another app, Launchpad / Trash / Downloads, or a fullscreen frontmost app | Leave the click to macOS. |

The toggle uses the app's current window state; it does not keep a separate list of windows that *it* minimized. For Finder, it only targets standard Finder windows. Apps that do not expose their windows through macOS Accessibility may not respond.

## Get started

There is currently **no downloadable Release for this fork**. Build it locally:

```bash
git clone https://github.com/chengen1018/Click2Minimize.git
cd Click2Minimize
xcodebuild -project Click2Minimize.xcodeproj -scheme Click2Minimize \
  -configuration Release -derivedDataPath build
```

The app will be at `build/Build/Products/Release/Click2Minimize.app`. Move it to Applications if you want, then launch it. To build an ad-hoc signed universal DMG at `dist/Click2Minimize.dmg`, run `./build_dmg.sh` instead.

1. In **System Settings → Privacy & Security → Accessibility**, allow Click2Minimize. Relaunch the app after granting access.
2. When macOS asks, allow **Automation → System Events** so the app can read Dock icon names and positions.
3. Use the menu bar icon to enable or disable the toggle, or turn on **Launch at login**. The toggle is on by default and launch at login is off by default.

> A locally built, ad-hoc signed app may require **Open** from Finder's context menu on first launch.

## Architecture

<p align="center"><img src="assets/architecture-en.svg" alt="Architecture: workspace notifications refresh the Dock map; a mouse event is matched to a Dock item, checked, and used to minimize or restore accessible windows" width="100%"></p>

The two paths meet at the cached Dock map:

- **Refresh:** `NSWorkspace` launch, activation, termination, and Space changes are debounced for 300 ms. AppleScript asks System Events for Dock item names and bounds.
- **Click:** a `CGEvent` tap sees left mouse-down events. The handler matches the click to a cached Dock item, then checks whether the feature is enabled, the app is active, and the frontmost app is not fullscreen.
- **Window action:** `AXUIElement` reads the app's windows. Visible windows take priority and are minimized; when none are visible, minimized windows are restored. If no action applies, the original click passes through.

The current startup path does not invoke the update-check functions. Dock discovery depends on macOS Accessibility and System Events permissions.

## What this fork changes

- Prioritizes visible windows; a later click restores all eligible minimized windows, even those minimized manually.
- Restricts Finder handling to standard Finder windows.
- Applies changes to multiple windows one at a time to accommodate apps whose Accessibility window lists update asynchronously.
- Adds local tests for the window-action decision. See [CHANGELOG.md](CHANGELOG.md) for the change history.

## Origin and license

The original project is [Click2Minimize by Hatim El Hassak](https://github.com/hatimhtm/Click2Minimize). This repository is a derivative, not an independent rewrite. The original work and derivative portions remain subject to the [PolyForm Noncommercial 1.0.0 license](LICENSE). Read [NOTICE.md](NOTICE.md) and [LICENSE](LICENSE) before redistributing or adapting the project.
