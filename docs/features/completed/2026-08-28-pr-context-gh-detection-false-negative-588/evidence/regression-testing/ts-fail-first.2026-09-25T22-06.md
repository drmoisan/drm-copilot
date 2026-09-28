# TS Fail-First ([P2-T5])

Timestamp: 2026-09-26T21-35

Command: `node run-jest.cjs test/lib/pr-context/pr-context-service-call.test.ts test/extension.collect-pr-context-gh-resolution.test.ts test/lib/pr-context/collector-core.test.ts --verbose` (from `extensions/drm-copilot`, pre-fix production code)

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- `Tests:       3 failed, 16 passed, 19 total` (`Test Suites: 3 failed, 3 total`)
- Zero `error TS` lines.
- The configured reporter printed only failing titles under `--verbose`; per-title pass status was read from a supplementary run of the same selection with `--json --outputFile=<session scratch file>` (exit 1, identical counts).
- Failed titles (verbatim):
  - S1: `collectPrContextServiceCall › invokes the resolved gh with auth status and reports the authenticated repository` — `expect(received).toContainEqual(expected)`; `Expected value: ["/usr/bin/gh", "auth", "status"]`; the received `runner.calls` contains only `git` argv, so `runner.calls` lacks `[GH_PATH, "auth", "status"]`.
  - C1: `drm-copilot collectPrContext gh resolution › collectPrContext spawns the PATH-resolved gh with auth status` — `expect(jest.fn()).toHaveBeenCalledWith(...expected)`; `Expected: "/opt/gh-bin/gh", ["auth", "status"], Anything`; `spawnSync` was not called with that argv.
  - K1: `collectPrContext autoclose body availability › renders the unavailable autoclose body when gh is not resolved` — `Expected substring: "None (GitHub CLI unavailable; closing issues not verified)"`.
- Passed titles: C2 `collectPrContext does not spawn gh when no PATH directory contains it`; K2 `keeps the readiness-not-PASS autoclose body when gh is available and nothing is listed`; and every other title in the three files (6 pre-existing collector-core titles, 8 pre-existing service-call titles).
- State: `TS_BUILDER_STATE: PARAM-ONLY`, `TS_CALLSITE: PRESENT`, so K1 was expected to fail. Failed set equals {S1, C1, K1}. Acceptance met.
