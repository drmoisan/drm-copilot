# Final QC: Full Pester (Issue #710)

Timestamp: 2026-09-27T02-45
Command: script A: sh <SCRATCHPAD>/r-full-a.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-full-a.ps1: print RUN_START_UTC; Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <WORKSPACE_ROOT>); script B: sh <SCRATCHPAD>/r-full-b.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-full-b.ps1: parse artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Pass 2. Full Pester run passed: console "Tests Passed: 5235, Failed: 0, Skipped: 9"; JUnit 5244 tests, 0 failures, 0 errors (baseline 5206; the difference of 38 is the new ChainEscape suite). JUnit written after the run start. No JUNIT_FAILED entry. ChainEscape row tests=38 failures=0 errors=0; the Parity, legacy-codex, test-name-uniqueness, and all HRS rows read failures=0 errors=0. git status --porcelain after the run lists only feature-folder paths.

Pass: 2

## Script A

```text
RUN_START_UTC: 2026-09-27T06:41:36.7835329Z
Tests Passed: 5235, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

The `Tests Passed:` console line is recorded with its ANSI color escape sequences removed.

## Script B

```text
JUNIT_LAST_WRITE_UTC: 2026-09-27T06:45:38.0543461Z
JUNIT_TESTS: 5244
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
```

`JUNIT_LAST_WRITE_UTC` (06:45:38Z) is after `RUN_START_UTC` (06:41:36Z).

JUNIT_FAILED entries: none

## Suite Rows (ChainEscape, the 10 HRS files, test-name-uniqueness)

```text
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 tests=38 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=55 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests=43 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 tests=5 failures=0 errors=0
```

## Acceptance Check

- `JUNIT_LAST_WRITE_UTC` is at or after `RUN_START_UTC`: yes.
- Every `JUNIT_FAILED:` entry is in `B_FULL`: there are no `JUNIT_FAILED:` entries (`B_FULL` is empty).
- ChainEscape row reads `tests=38 failures=0 errors=0`: yes.
- Parity, legacy-codex, and test-name-uniqueness rows read `failures=0 errors=0`: yes.

## Porcelain After Run

```text
 M docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md
?? docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/
```
