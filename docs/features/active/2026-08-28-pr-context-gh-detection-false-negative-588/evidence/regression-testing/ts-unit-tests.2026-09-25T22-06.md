# TS Unit Tests ([P6-T3])

Timestamp: 2026-09-26T22-01

Command: `node run-jest.cjs test/lib/executable-resolver.test.ts test/lib/pr-context/render-pr-helpers.test.ts test/lib/pr-context/pr-context-service-call-target.test.ts test/repo-automation-dispatch-pr-context-verification.test.ts test/extension.integration.test.ts --verbose` (from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary:
- `Test Suites: 5 passed, 5 total`
- `Tests:       68 passed, 68 total` (0 failed)
- Per-title status read from a supplementary run of the same selection with `--json --outputFile=<session scratch file>` (exit 0, identical counts), because the reporter lists only failures under `--verbose`.
- passed (R1-R11, `resolveExecutableOnPath`):
  - R1 `returns the gh.exe candidate for a win32 PATH and PATHEXT`
  - R2 `matches a lower-case PATHEXT entry against an existing gh.exe`
  - R3 `tries a name that already ends in a PATHEXT extension as-is`
  - R4 `returns the posix candidate from the first PATH directory that contains the name`
  - R5 `ignores PATHEXT on non-win32 platforms`
  - R6 `returns the earlier directory's match when several directories contain the name`
  - R7 `returns undefined when no candidate exists`
  - R8 `returns undefined for an undefined PATH`
  - R9 `returns undefined for an empty PATH`
  - R10 `skips empty PATH entries`
  - R11 `falls back to the default PATHEXT list when PATHEXT is unset`
- passed (D1-D2, `defaultWhichGh`):
  - D1 `resolves gh from process PATH, PATHEXT, and platform through fs.existsSync`
  - D2 `returns undefined when fs.existsSync reports no candidate`
- passed (H1-H4 and existing fallbacks, `buildIssuesToAutocloseSection`):
  - H1 `reports GitHub CLI unavailable when gh is unavailable and nothing is listed`
  - H2 `prefers the unavailable text over the PASS fallback when gh is unavailable`
  - H3 `lists pending refs and omits the empty-list unavailable body when gh is unavailable`
  - H4 `keeps both available fallback texts when ghAvailable is true`
  - `uses the PASS fallback text when nothing is present and readiness is PASS`
  - `uses the non-PASS fallback text otherwise`
- Every other title in the five files passed (target, dispatch-verification, and integration suites included).
