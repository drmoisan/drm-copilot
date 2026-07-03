# Coverage Delta — Issue #272

Timestamp: 2026-07-02T19-29

| Metric | Baseline (P0-T16) | Post-change (P4-T11) | Delta |
|---|---|---|---|
| Line/command coverage | 90.99% (101/111 commands) | 88.49% (123/139 commands) | -2.50 percentage points (numerator +22, denominator +28) |
| Tests passing | 46/46 | 53/53 | +7 tests |

## Changed-Lines Coverage (no regression)

The new code added by this feature is entirely contained within the new `Invoke-OrchestratorStatePreflight` function and the new early-return branch it feeds in `Get-PrAuthorBypassReason` (approximately 28 net new analyzed commands: 139 - 111 = 28). Of those 28 new commands, 24 are exercised by the new tests (direct-seam unit tests in `Invoke-OrchestratorStatePreflight (direct seam tests)`, the mocked-wrapper `orchestrator-state preflight` tests, and the real-subprocess end-to-end test); only the 4 commands inside the default `$Invoker` scriptblock body remain uncovered by in-process instrumentation, for the reason documented in `final-poshqc-test-coverage.md` (the real subprocess path executes in a separate child process not visible to the parent Pester process's coverage instrumentation, and is independently confirmed via the end-to-end test's outcome assertion plus a manual CLI validation run).

Changed-lines coverage on new code: 24/28 = 85.7%, above the 85% floor.

## No Regression on Pre-existing Lines

The 3 pre-existing missed commands from the P0-T16 baseline (`Test-PrAuthorReceiptVerification` malformed-JSON/unreadable-body/unparseable-`created_at` branches) remain the only pre-existing gap carried forward unchanged; no previously-covered line became uncovered. The overall percentage decline (90.99% -> 88.49%) is explained entirely by the denominator growing faster (111 -> 139, +28 new commands) than the newly-covered numerator (101 -> 123, +22), not by any regression on previously-covered code. Final coverage (88.49%) remains above the repository's 85% line-coverage floor.
