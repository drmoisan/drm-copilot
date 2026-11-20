# Phase 0 Full Pester Baseline (Issue #710)

Timestamp: 2026-09-27T02-09
Command: script A: sh <SCRATCHPAD>/r-full-a.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-full-a.ps1: print RUN_START_UTC; Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <WORKSPACE_ROOT>); script B: sh <SCRATCHPAD>/r-full-b.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-full-b.ps1: parse artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Full Pester run passed: console "Tests Passed: 5197, Failed: 0, Skipped: 9"; JUnit 5206 tests, 0 failures, 0 errors. JUnit written after the run start. B_FULL is empty.

## Script A

```text
RUN_START_UTC: 2026-09-27T06:05:10.9231603Z
Tests Passed: 5197, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

## Script B

```text
JUNIT_LAST_WRITE_UTC: 2026-09-27T06:09:11.3664527Z
JUNIT_TESTS: 5206
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
```

JUNIT_FAILED entries: none

Suite rows of interest (from script B):

```text
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 tests=5 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=55 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests=43 failures=0 errors=0
```

## B_FULL

none
