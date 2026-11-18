# Task check - P1-T3 ([expect-fail])

Timestamp: 2026-11-17T22-07
Changed files (all new test files):
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Cases.ps1 (101 shared rows)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1
Selection rule: the two new decision suites plus the discovery guard `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, which reads every hook suite.

Commands:
1. Command: sh SCRATCH/issue-1201-ps-static.sh <the three files>
   EXIT_CODE: 0
   Output Summary: format drift 0, PSScriptAnalyzer findings 0 (re-run after each edit below, 0 findings each time).
2. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the two decision suites> tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
   EXIT_CODE: 1
   Output Summary: every discovery-guard row and both interception probes passed (no failure outside the release-allowance rows). AC-18 failed on both surfaces with "No mock for command 'Read-OrchestrationGateCheckpoint' matched the call" (Pester 6 has no fall-through to the original command); a default mock that calls the original function was added.
3. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the two decision suites>
   EXIT_CODE: 1
   Output Summary: AC-18 failed with a parameter-binding error because the default mock used GetNewClosure, which hides PesterBoundParameters; the mock now calls the original through a script-scope reference.
4. Command: the same two-suite launcher selection (recorded fail-before, evidence/regression-testing/fail-before.2026-11-17T22-06.md)
   EXIT_CODE: 1 (expected)
   Output Summary: expected failures only. Per surface: 6 rows pass (AC-4 x2, AC-5 x2, AC-6, AC-18) and 95 rows fail because the gate returns the generic deny text without the leg (34 allow rows return deny, the suffix rows lack the release suffix). The failing row ids are listed by name in the fail-before artifact; P1-T4 makes them pass.
