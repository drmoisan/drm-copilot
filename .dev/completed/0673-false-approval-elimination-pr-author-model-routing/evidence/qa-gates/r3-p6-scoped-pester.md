# Phase 6 Scoped Pester Verification (issue #673)

Timestamp: 2026-09-19T18-32

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-lib`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-lib -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-report.ps1`.

EXIT_CODE: 0

## Report freshness

- JUnit report last write (UTC): `2026-09-19T18:33:40Z`, later than this artifact's `Timestamp:` of `2026-09-19T18-32`.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 1520 |
| `failures` | 0 |
| `errors` | 0 |

Testcases carrying a `failure` child: none.

## The two testsuites

| Testsuite | tests | failures | skipped | disabled | passed |
| --- | --- | --- | --- | --- | --- |
| `OrchestratorState.Tests.ps1` | 46 | 0 | 0 | 0 | 46 |
| `OrchestratorState.ValueContract.Tests.ps1` | 2 | 0 | 0 | 0 | 2 |

The value-contract testsuite has 2 passed, which are the two rows moved out of the source suite. The source suite fell from 48 tests to 46, the difference being exactly those two, so the move added and lost nothing.

## Line counts

| File | Lines | Under the 500-line cap |
| --- | --- | --- |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | 491 | yes |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1` | 86 | yes |

The source suite was 509 lines at baseline, a pre-existing breach of the cap that RS-14 records and this phase closes. Removing the 25-line block took it to 484; the `[P6-T3]` pin replacement added seven lines, leaving 491 with nine lines of headroom.

Output Summary: All four acceptance conditions hold. The report post-dates this artifact's timestamp; the root records `failures 0` and `errors 0`; the value-contract testsuite has 2 passed; and both files are at most 500 lines, at 491 and 86. The pre-existing 509-line cap breach in `OrchestratorState.Tests.ps1` is resolved, and the end-to-end row whose script-variable pin was removed still reaches `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` through the unmocked preflight.
