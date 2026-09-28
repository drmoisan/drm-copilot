# Remediation Cycle 1 - Final Full Pester ([P4-T6])

Timestamp: 2026-09-27T05-26

Pass: 1

Command: sh <SCRATCHPAD>/x713-fulla.sh (R-FULL script A: `Invoke-PoshQCTest -Root <WORKSPACE_ROOT>`), then sh <SCRATCHPAD>/x713-fullb.sh (R-FULL script B: JUnit parse)

EXIT_CODE: 0

MCP_CALL: mcp__drm-copilot__run_poshqc_test workspace_root=<WORKSPACE_ROOT> scan_folders=(none) -> ok=true (disposition only; no counts are read from the MCP result)

Output Summary: Script A: Tests Passed 5309, Failed 0, Skipped 9, NotRun 0 (Pester console summary). Script B (EXIT_CODE 0): JUNIT_TESTS 5318, JUNIT_FAILURES 0, JUNIT_ERRORS 0; no JUNIT_FAILED line; no JUNIT_SUITE_MISSING line. AttributionTrailer row `tests=74 failures=0 errors=0`; Parity and legacy-codex rows `failures=0 errors=0`; all 18 HRS rows `failures=0 errors=0`. C1_B_FULL is empty, so no failure needs to be matched against it. Result: PASS.

RUN_START_UTC: 2026-09-27T09:20:57.7297952Z

JUNIT_LAST_WRITE_UTC: 2026-09-27T09:24:42.2789059Z

JUNIT_TESTS: 5318

JUNIT_FAILURES: 0

JUNIT_ERRORS: 0

JUNIT_FAILED: none

JUNIT_SUITE_MISSING: none printed

## JUNIT_SUITE rows (AttributionTrailer suite and the 18 HRS files)

```text
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 tests=74 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 tests=15 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 tests=56 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 tests=33 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 tests=7 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=87 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 tests=19 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 tests=35 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests=119 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 tests=55 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 tests=11 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 tests=23 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests=43 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 tests=38 failures=0 errors=0
```

## Script A console summary

```text
Tests completed in 165.56s
Tests Passed: 5309, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 95.24% / 0%. 14,500 analyzed Commands in 112 Files.
```

The full JUNIT_SUITE listing (every suite `failures=0 errors=0`) is held in `<SCRATCHPAD>/c1-p4-fullb.txt`.
