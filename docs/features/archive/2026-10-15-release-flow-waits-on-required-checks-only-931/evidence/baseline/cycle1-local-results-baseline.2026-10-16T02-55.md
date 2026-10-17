# Cycle 1 Local Results Baseline (Issue #931)

Timestamp: 2026-10-16T02-55
Scope: values come from the scoped call of cycle1-ps-test (scan_folders = ["tests/scripts/dev-tools"]), not from a full-suite run.

Schema observed: root element `<testsuites name="Pester" tests=... errors=... failures=... disabled=... time=...>` in artifacts/pester/pester-junit.xml; total in `tests`, failures in `failures`, errors in `errors`.

BASELINE_TESTS: 654
BASELINE_FAILURES: 0
BASELINE_ERRORS: 0
JUNIT_WRITTEN: 2026-10-16T02-55 (date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M; output was a 16-character stamp)
CALL_TS: 2026-10-16T02-52

JUNIT_WRITTEN >= CALL_TS (lexicographic): true.

Output Summary: scoped run totals 654 tests, 0 failures, 0 errors (disabled=2 per root attribute); file written after the P0-T14 call.
