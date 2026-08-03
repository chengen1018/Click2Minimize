# Changelog

## Unreleased — Chengen maintenance version

This entry records the current derivative-work snapshot. It is not an upstream Click2Minimize release.

### Added

- A visible-window-first toggle decision: visible windows are minimized; when none are visible, all minimized windows are restored.
- Restoration of windows that were manually minimized before the toggle.
- Finder filtering for standard, minimizable Finder windows.
- Local decision tests and design/implementation documentation.

### Changed

- The Dock click handler now uses `toggleAppWindows(for:)` instead of only minimizing windows.
- Startup no longer invokes the automatic release update check in this maintenance snapshot.

### Attribution

This is a derivative work based on [Click2Minimize](https://github.com/hatimhtm/Click2Minimize) by Hatim El Hassak. See [NOTICE.md](NOTICE.md) and [LICENSE](LICENSE).

## 2026-08-03 — multi-window and Steam fixes

- Apply minimize/restore operations to multiple AX windows sequentially, allowing apps with asynchronous window updates to process every window.
- Resolve Dock app names by preferring the current frontmost process and then a same-name process with accessible windows, avoiding Steam Helper selection.
- Toggle Steam's main process and `com.valvesoftware.steam.helper` together because Steam's visible UI spans both processes.
