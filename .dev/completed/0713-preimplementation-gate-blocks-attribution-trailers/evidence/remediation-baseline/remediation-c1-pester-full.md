# Remediation Cycle 1 - P0-T9 Full Pester Baseline

Timestamp: 2026-09-27T04-58
Command: sh <SCRATCHPAD>/x713-fulla.sh (R-FULL script A: Invoke-PoshQCTest -Root <WORKSPACE_ROOT>)
EXIT_CODE: 0
SCRIPT_B_EXIT_CODE: 0 (sh <SCRATCHPAD>/x713-fullb.sh, reads artifacts/pester/pester-junit.xml)
Output Summary: Full Pester run: 5303 passed, 0 failed, 9 skipped (console). JUnit: 5312 tests, 0 failures, 0 errors. The AttributionTrailer suite row reads tests=68 failures=0 errors=0; all 18 HRS rows read failures=0 errors=0. The JUnit file was written after the run started. The tree was unchanged across the run.

RUN_START_UTC: 2026-09-27T08:54:09.9293564Z
JUNIT_LAST_WRITE_UTC: 2026-09-27T08:58:15.2934253Z
JUNIT_TESTS: 5312
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0
JUNIT_FAILED: none

Script A console summary (ANSI color codes removed):

```text
Tests completed in 166.85s
Tests Passed: 5303, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

## JUNIT_SUITE lines (HRS files and the AttributionTrailer suite)

```text
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 tests=33 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 tests=38 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=87 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 tests=68 failures=0 errors=0
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

## C1_B_FULL

none (no JUNIT_FAILED entries)

## Tree Delta

Porcelain before script A (`git status --porcelain`):

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/remediation-baseline/
```

Porcelain after script B (`git status --porcelain`):

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/remediation-baseline/
```
