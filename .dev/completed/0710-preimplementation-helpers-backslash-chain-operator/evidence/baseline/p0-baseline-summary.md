# Phase 0 Baseline Gate Summary (Issue #710)

Timestamp: 2026-09-27T02-10

Sources: p0-scoped-coverage.md, p0-poshqc-format.md, p0-poshqc-analyze.md, p0-pester-full.md, p0-pytest-push-down.md.

## Halting Checks

| Check | Source | Result |
| --- | --- | --- |
| No `FAILED:` path belongs to the Parity or legacy-codex suites | [P0-T6] | GREEN (no FAILED lines) |
| Both `percent=` values at least 85 | [P0-T6] | GREEN (97.04 and 97.04) |
| `Formatted: ` count is 0 | [P0-T7] | GREEN (0) |
| Analyzer records `PSScriptAnalyzer passed: no findings under` | [P0-T8] | GREEN |
| No `JUNIT_FAILED:` entry in the Parity, legacy-codex, or test-name-uniqueness suites | [P0-T9] | GREEN (no JUNIT_FAILED entries) |

## Recording Checks (rule 9, no halt)

| Check | Source | Result |
| --- | --- | --- |
| `FailedCount: 0` | [P0-T6] | GREEN |
| `JUNIT_FAILURES: 0` and `JUNIT_ERRORS: 0` | [P0-T9] | GREEN |
| No failed pytest node | [P0-T10] | GREEN (14 passed) |

## Pre-existing Failure Sets

- B_SCOPED: none
- B_FULL: none

Every halting row reads GREEN; execution proceeds to Phase 1.
