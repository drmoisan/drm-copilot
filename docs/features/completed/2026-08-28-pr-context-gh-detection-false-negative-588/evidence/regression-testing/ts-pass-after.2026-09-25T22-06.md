# TS Pass-After ([P6-T1])

Timestamp: 2026-09-26T21-58

Command: `node run-jest.cjs test/lib/pr-context/pr-context-service-call.test.ts test/extension.collect-pr-context-gh-resolution.test.ts test/lib/pr-context/collector-core.test.ts --verbose` (from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary:
- `Test Suites: 3 passed, 3 total`
- `Tests:       19 passed, 19 total` (0 failed)
- Per-title status read from a supplementary run of the same selection with `--json --outputFile=<session scratch file>` (exit 0, identical counts), because the reporter lists only failures under `--verbose`.
- passed: S1 `collectPrContextServiceCall › invokes the resolved gh with auth status and reports the authenticated repository`
- passed: C1 `drm-copilot collectPrContext gh resolution › collectPrContext spawns the PATH-resolved gh with auth status`
- passed: C2 `drm-copilot collectPrContext gh resolution › collectPrContext does not spawn gh when no PATH directory contains it`
- passed: K1 `collectPrContext autoclose body availability › renders the unavailable autoclose body when gh is not resolved`
- passed: K2 `collectPrContext autoclose body availability › keeps the readiness-not-PASS autoclose body when gh is available and nothing is listed`
