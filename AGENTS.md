## Project Overview

SeamlessPay iOS SDK — a payment SDK providing card form UI, Apple Pay integration, and API client for tokenization, charges, and refunds. Zero external dependencies. Supports Swift Package Manager and CocoaPods.

- **Swift 5.8+**, **iOS 15+**
- Main branch: `main`

## AI-assisted Engineering Principles

This team uses AI tooling as an assistive technology to improve delivery of quality code. AI should be used judiciously — focus on helping produce correct, well-tested, maintainable code rather than generating volume.

## Agent Protocol

- **Unsure: read more code; if still stuck, ask with short options.**
- **Conflicts: stop + ask.**
- **If code is confusing:** simplify it; add an ASCII art diagram comment if it helps.
- **Build and verify after editing** — catches breakage before it compounds across later edits.

## Git

- Safe by default: `git status/diff/log`. Push only when user asks.
- Branch changes require user consent.
- Don't commit, and push; stop + ask.
- Don't delete/rename unexpected stuff; stop + ask.
- No amend unless asked.

### Commit Conventions

- Format: `type [SDKI-###]: Description` (e.g., `feat [SDKI-188]: Add new model`)
- Types: `feat`, `fix`, `refactor`, `chore`, `style`
- Releases: `chore(release): X.Y.Z`

## Build & Test Commands

**Build:**
```bash
xcodebuild -workspace ./.swiftpm/xcode/package.xcworkspace -scheme SeamlessPay -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build
```

**Run all tests:**
```bash
xcodebuild -workspace ./.swiftpm/xcode/package.xcworkspace -scheme SeamlessPay -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' -enableCodeCoverage YES CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO test
```

**Lint & format:**
```bash
swiftlint
swiftformat .
```

## Architecture

**Two SPM targets:**
- `SeamlessPay` (Swift) — main public SDK, depends on SeamlessPayObjC
- `SeamlessPayObjC` (ObjC) — legacy card validation, brand detection, image assets

**Source layout:**
- `SeamlessPay/API/` — `APIClient` with async/await networking, models, response types, error handling
- `SeamlessPay/UI/` — `CardForm` (UIView subclass) + `CardFormViewModel` (MVVM), `ApplePayHandler`, `LineTextField`
- `SeamlessPay/Utils/` — Card image manager, currency helpers
- `ObjC/include/` — Card validators, brand enums, text field delegates, string extensions, image resources
- `SwiftSentryClient/` — Integrated Sentry error reporting (`SPSentryClient`)

**Test layout:**
- `Tests/SeamlessPayTests/` — Swift tests (APIClient, SentryClient, UI, Utils)
- `Tests/SeamlessPayTestsObjC/` — ObjC tests
- Mocking via `APIClientURLProtocolMock` (custom URLProtocol)

## Code Style

- **2-space indentation**, max line width 100 (swiftformat), 120 (swiftlint)
- SwiftFormat and SwiftLint configs at repo root (`.swiftformat`, `.swiftlint.yml`)
- Extensions named: `APIClient+Concurrency.swift`, `CardForm+Client.swift`
- Test files named: `*Test.swift`
- SwiftLint excludes `Tests/` directory

## Skills Name Convention

Use **gerund form** (verb + -ing) for skill names. Stable categories: `managing-`, `maintaining-`, `developing-`. Examples: `developing-code-explain`. Lowercase letters, numbers, and hyphens only.
