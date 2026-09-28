# P5-T6 Final Full Pester Run

Timestamp: 2026-09-27T03-55
Pass: 1
Command: sh <SCRATCHPAD>/x713-fulla.sh (R-FULL script A: Invoke-PoshQCTest -Root $root) then sh <SCRATCHPAD>/x713-fullb.sh (R-FULL script B: reads artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Full Pester run passed: 5303 passed, 0 failed, 9 skipped (runner summary); JUnit reports 5312 tests, 0 failures, 0 errors (68 more than baseline, the new suite). The new AttributionTrailer suite row reads tests=68 failures=0 errors=0, no suite is missing, and all 18 HRS rows, including Parity and legacy-codex, read failures=0 errors=0.

MCP_CALL: returned (mcp__drm-copilot__run_poshqc_test, workspace_root <WORKSPACE_ROOT>, no scan_folders; result carries ok=true and a pre-run summary only, per plan rule 5)

Other commands: R-FULL script B, EXIT_CODE 0.

RUN_START_UTC: 2026-09-27T07:51:21.9644831Z
JUNIT_LAST_WRITE_UTC: 2026-09-27T07:55:31.0953862Z
JUNIT_TESTS: 5312
JUNIT_FAILURES: 0
JUNIT_ERRORS: 0

JUNIT_FAILED lines: none
JUNIT_SUITE_MISSING lines: none

Runner summary line (script A): `Tests Passed: 5303, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`.

## JUNIT_SUITE lines (new suite and HRS files)

```text
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 tests=68 failures=0 errors=0
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

B_FULL is empty and no JUNIT_FAILED entry exists.
