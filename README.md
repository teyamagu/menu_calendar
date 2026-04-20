# MenuCalendar

A small macOS menu bar calendar app.  
It is **open source** and accepts improvements via Issues and pull requests.

## Features

- Menu bar shows `weekday yyyy/MM/dd HH:mm` (follows the **macOS system time zone**; changing system settings updates the display)
- Click to open the current month’s calendar
- Previous / next month navigation
- **Today** jumps back to the current date
- Optional **Launch at Login** toggle in the menu
- Quit from the menu (`⌘Q`)

## Tech stack

- Swift
- SwiftUI (`MenuBarExtra`)
- Swift Package Manager (SPM)
- Modules: SPM targets `MenuCalendarCore` (shared library), `MenuCalendarUI` (app UI), `App` (`@main`)

## Requirements

- macOS 13 or later
- Xcode or Command Line Tools (environment where Swift runs)

## Run locally

```bash
swift run MenuCalendar
```

## Tests

```bash
swift test
```

- **Core**: formatter, month navigation, `MonthCalendarModel`, `MenuCalendarCalendarFactory`, etc. — `Tests/MenuCalendarTests.swift`, `TestSupport.swift`
- **SwiftUI / state**: `MonthCalendarDisplay`, `MenuCalendarState` + `ClockModel`, menu bar follows `TimeZone.autoupdatingCurrent` — `Tests/MenuCalendarUITests.swift` ([ViewInspector](https://github.com/nalexn/ViewInspector))

## Code style (SwiftLint / SwiftFormat)

Config files at the repo root: `.swiftlint.yml`, `.swiftformat` (excludes `.build`, `dist`, etc.).

```bash
brew install swiftlint swiftformat
```

Same checks as CI:

```bash
./scripts/lint.sh
```

Or run tools separately:

```bash
swiftformat . --lint --config .swiftformat
swiftlint lint --strict --config .swiftlint.yml
```

Apply SwiftFormat (writes files):

```bash
swiftformat . --config .swiftformat
```

## CI (GitHub Actions)

On every **push** to `main` and every **pull request** targeting `main`, the workflow runs **SwiftFormat (`--lint`)**, **SwiftLint (`--strict`)**, and **`swift test`** on **`macos-15`** (Xcode 16 / Swift 6 — required to build ViewInspector 0.10.x). See `.github/workflows/ci.yml`.

## Build as a macOS `.app`

### Recommended (bundled icon)

```bash
./scripts/build_macos_app.sh
```

Output:

- `dist/MenuCalendar.app`

Open:

```bash
open "dist/MenuCalendar.app"
```

### Manual (reference)

```bash
swift build -c release --product MenuCalendar
```

The binary is at `.build/release/MenuCalendar`.  
For a `.app` bundle, use the recommended script above.

## Install from GitHub Releases

### For users

1. Download `MenuCalendar-x.y.z.zip` from **Releases**.
2. Unzip; you get `MenuCalendar.app` and `LICENSE` (full MIT text).
3. Move `MenuCalendar.app` to **Applications** or run it from the unzipped folder.

#### First launch (Gatekeeper)

Some builds may **not** be signed with Apple Developer ID or **notarized**. macOS may show **“cannot be opened because the developer cannot be verified”** (or similar), and double-click alone may not open the app.

Try one of the following:

- In Finder, **Control-click** `MenuCalendar.app` → **Open**, then confirm **Open** in the dialog.
- If it still fails, follow macOS guidance under **System Settings → Privacy & Security** (wording varies by macOS version).

##### “App is damaged and can’t be opened”

ZIPs from a browser often add the **quarantine** extended attribute. Gatekeeper may show this message even when the app is **not** actually corrupted.

Remove quarantine, then open again (adjust the path to your copy of `MenuCalendar.app`):

```bash
xattr -dr com.apple.quarantine /Applications/MenuCalendar.app
```

If the app lives in **Downloads** or on the **Desktop**, use that path instead. To strip extended attributes broadly (removes more than quarantine):

```bash
xattr -cr ~/Downloads/MenuCalendar.app
```

For wider distribution, consider **Developer ID signing and notarization** to reduce user friction.

#### Privacy

The app **does not collect or send data over the network**; it only does on-device work needed to show the calendar and time.

### For maintainers: release ZIP

To build the ZIP attached to a GitHub release (`MenuCalendar.app` + root `LICENSE`):

```bash
./scripts/package_github_release.sh 1.0.1
```

Output: `dist/MenuCalendar-1.0.1.zip`. The script prints **SHA256** for release notes if you need it.

## Contributing

Contributions are welcome — from typo fixes to new features. Please open a PR.

### 1. Open an issue (recommended)

- **Bugs**: steps to reproduce, expected vs actual behavior, environment
- **Features**: goal, use case, alternatives you considered

### 2. Create a branch

```bash
git checkout -b feature/short-description
```

### 3. Implement and test

- Add or update tests for your change
- Keep `swift test` green
- Avoid breaking existing behavior unintentionally

### 4. Commit

- Prefer messages that explain **why**, not only **what**
- One commit per logical change when practical

### 5. Open a pull request

Include:

- Summary (what problem it solves)
- Main changes
- What you tested
- Screenshots if the UI changed

## Maintainer notes

- Breaking or behavioral changes: discuss in an issue first when possible
- Reviews focus on readability, maintainability, and tests
- Responses may be delayed

## Security

For sensitive issues, contact maintainers privately instead of posting details in a public issue first.

## License

MIT License

- See `LICENSE`
- SPDX-License-Identifier: `MIT`
