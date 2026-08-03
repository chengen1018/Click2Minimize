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
