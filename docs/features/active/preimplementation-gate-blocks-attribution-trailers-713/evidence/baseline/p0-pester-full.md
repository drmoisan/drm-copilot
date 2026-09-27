# P0-T12 Full Pester Baseline

Timestamp: 2026-09-27T03-31
Command: sh <SCRATCHPAD>/x713-fulla.sh (R-FULL script A: Invoke-PoshQCTest -Root $root) then sh <SCRATCHPAD>/x713-fullb.sh (R-FULL script B: reads artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Full Pester run passed: 5235 passed, 0 failed, 9 skipped (runner summary); JUnit reports 5244 tests, 0 failures, 0 errors. All 18 HRS suites read failures=0 errors=0. B_FULL is empty. The porcelain status before and after the run is identical (TREE_DELTA_PATHS: none).

Other commands:

- R-FULL script B: EXIT_CODE 0
- `git status --porcelain` (before): EXIT_CODE 0
- `git status --porcelain` (after): EXIT_CODE 0

RUN_START_UTC: 2026-09-27T07:26:06.3704452Z
JUNIT_LAST_WRITE_UTC: 2026-09-27T07:30:08.2561349Z
JUNIT_TESTS: 5244
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0

JUNIT_FAILED lines: none

Script B also printed `JUNIT_SUITE_MISSING: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`. This is expected at baseline because the new suite is created in [P1-T2]; the missing-suite condition is a failure only for the Phase 5 reading task [P5-T6].

Runner summary line (script A): `Tests Passed: 5235, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`.

## JUNIT_SUITE lines for the HRS files

```text
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 tests=33 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 tests=38 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=87 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 tests=56 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=55 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests=43 failures=0 errors=0
```

## B_FULL

none

## Tree Delta

Before:

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/
```

After:

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/
```

TREE_DELTA_PATHS: none
