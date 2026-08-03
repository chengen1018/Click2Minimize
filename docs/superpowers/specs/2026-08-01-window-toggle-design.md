# Native Window Toggle Design

## Goal

Create a local macOS menu-bar utility that toggles Dock-selected application windows while preserving native minimization behavior: a single window minimizes into the Dock, and a second click restores the same window. For applications with multiple windows, a second click restores every minimized window for that application, including windows minimized manually. Finder is handled without treating its desktop process as an ordinary window.

## Scope

- Target macOS 13+ and Apple Silicon arm64.
- Retain the existing CGEvent Dock-click monitor and Accessibility permission model.
- Do not use screen-recording access, private frameworks, network services, external dependencies, or AppleScript for window state changes.
- Preserve the original Dock event whenever the current window snapshot has no eligible action.

## Behavior

### Regular applications

1. A click on an inactive application is passed through to macOS unchanged.
2. A click on an active application with at least one visible, minimizable window minimizes every eligible visible window.
3. A click on an active application with no eligible visible windows and at least one eligible minimized window restores every eligible minimized window, including windows minimized manually before the utility ran.
4. A click on an active application with no eligible visible or minimized windows passes through to macOS unchanged.
5. A closed, invalid, or non-restorable window is skipped; other eligible windows still complete the selected action.

### Finder

1. Finder windows are eligible only when their Accessibility window role is a standard, minimizable Finder window.
2. The utility never tracks Finder's desktop/windowless system state.
3. If no eligible visible or minimized Finder windows exist, a Finder Dock click passes through to macOS without being consumed. The utility never creates a Finder window itself; any new default Finder window (for example, Recents) is solely macOS's result.
4. If eligible minimized Finder windows exist and no eligible visible Finder windows exist, the utility restores every eligible minimized Finder window rather than creating a new Finder window.

## Architecture

- `WindowToggleDecision`: describes `minimizeVisible`, `restoreMinimized`, or `passThrough` for a current Accessibility window snapshot.
- `WindowToggleController`: resolves one Dock click from the snapshot without storing prior minimization sessions.
- `AccessibilityWindowGateway`: isolates querying `kAXWindowsAttribute`, filtering eligible windows, and reading/writing `kAXMinimizedAttribute`.
- `DockClickRouter`: continues to resolve Dock clicks, then calls the controller and consumes an event only for a successful minimize or restore action.
- Existing settings/menu-bar code remains responsible only for enablement and launch-at-login.

## Failure handling

- Accessibility API failures always pass the original Dock click through rather than swallow it.
- Restore ignores stale Accessibility windows and continues restoring other eligible minimized windows.
- Full-screen applications continue to pass through untouched.

## Verification

- Unit-test the pure decision logic: single-window minimize/restore, multi-window restore-all, manually pre-minimized restore, empty-window pass-through, and Finder pass-through with no eligible Finder window.
- Use an injected window gateway for unit tests; use Accessibility APIs only in the production gateway.
- Perform a manual macOS check with Finder, a one-window application, and a multi-window application after a Release arm64 build.

## Non-goals

- Replacing the Dock.
- Managing full-screen windows, Spaces, Stage Manager, or screen previews.
