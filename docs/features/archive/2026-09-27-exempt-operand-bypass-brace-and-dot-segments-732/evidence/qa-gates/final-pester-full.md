# Final PoshQC full Pester run (issue #732)

Timestamp: 2026-10-09T04-55
Task: [P7-T8]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/r-full-a-bg.sh (R-FULL script A: Invoke-PoshQCTest -Root $root), then sh <SCRATCHPAD>/c1b732/p7-t8.sh (R-FULL script B, <SCRATCHPAD>/c1b732/rfb.ps1, package-join rule)
EXIT_CODE: 0

## Output

```text
PASS: 3
MCP_CALL: error Command exited with code 2. (mcp__drm-copilot__run_poshqc_test, no scan_folders)
RUN_START_UTC: 2026-10-09T04:47:09.3374293Z
RUNNER_SUMMARY: Tests Passed: 7795, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
SCRIPT_A_EXIT: 2
JUNIT_LAST_WRITE_UTC: 2026-10-09T04:55:30.5094457Z
JUNIT_TESTS: 7807
JUNIT_FAILURES: 2
JUNIT_ERRORS: 0
JUNIT_FAILED: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 :: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
JUNIT_FAILED: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 :: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
POSHQC_COVERAGE_LAST_WRITE_UTC: 2026-10-09T04:53:09.5766768Z
POSHQC_RULE: package-join
POSHQC_MATCH: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=156 missed=3 percent=98.11
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=156 missed=3 percent=98.11
POSHQC_MATCH: .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 covered=123 missed=0 percent=100.00
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 covered=123 missed=0 percent=100.00
POSHQC_MATCH: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=77 missed=1 percent=98.72
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=60 missed=0 percent=100.00
POSHQC_MATCH: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 package-join classes=1
POSHQC_LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 covered=165 missed=0 percent=100.00
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 tests=76 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests=12 failures=0 errors=0
JUNIT_SUITE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 tests=13 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests=84 failures=0 errors=0
JUNIT_SUITE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 tests=2 failures=0 errors=0
JUNIT_SUITE_MISSING: none
CHECK: TIMES_AFTER_RUN_START True
CHECK: JUNIT_FAILED_SUBSET_OF_B_FULL True
CHECK: NO_SUITE_MISSING True
CHECK: NEW_SUITES_CLEAN True
CHECK: POSHQC_RULE_RECORDED True
CHECK: SEVEN_MATCHES_CLASSES_1 True
CHECK: SEVEN_PERCENT_AT_LEAST_85 True
```

Output Summary: pass 3; done condition met: True; RUNNER_SUMMARY: Tests Passed: 7795, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0; JUnit JUNIT_TESTS: 7807 / JUNIT_FAILURES: 2; seven PoshQC line-coverage values (package-join):
  .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=156 missed=3 percent=98.11
  .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=156 missed=3 percent=98.11
  .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 covered=123 missed=0 percent=100.00
  .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 covered=123 missed=0 percent=100.00
  .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=77 missed=1 percent=98.72
  .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 covered=60 missed=0 percent=100.00
  .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 covered=165 missed=0 percent=100.00

