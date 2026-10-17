# Cycle 1 Local Final Results and Coverage Delta (Issue #931)

Timestamp: 2026-10-16T03-06
Scope: baseline and final values are both scoped-run values (scan_folders = ["tests/scripts/dev-tools"]); every comparison is scoped to scoped.

FINAL_CALL_TS: 2026-10-16T03-05
FINAL_JUNIT_WRITTEN: 2026-10-16T03-06
FINAL_COVERAGE_WRITTEN: 2026-10-16T03-06
Both written stamps >= FINAL_CALL_TS: true

Tests (artifacts/pester/pester-junit.xml root):
- FINAL_TESTS: 655
- FINAL_FAILURES: 0
- FINAL_ERRORS: 0
- BASELINE_TESTS (cycle1-local-results-baseline.2026-10-16T02-55.md): 654
- FINAL_TESTS equals BASELINE_TESTS + 1: true
- testcase for `reports unknown for a blank bucket value`: status="Passed" (junit line 411)

Coverage of scripts/dev-tools/Invoke-FullReleaseFlow.ps1 (class-level LINE counter, powershell-coverage.xml lines 17877-17880):
- baseline (cycle1-local-coverage-baseline.2026-10-16T02-55.md): covered 153, valid 160, percent 95.63
- final: covered 153, valid 160, percent 95.63 (153 / 160 x 100)
- delta: 0.00 percentage points
- final percent >= baseline percent: true
- final valid equals baseline valid: true (production script unchanged)

Output Summary: post-change scoped line coverage is 95.63% (153 of 160), unchanged from the 95.63% baseline; 655 tests, 0 failures, 0 errors.
