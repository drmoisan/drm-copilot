# PowerShell Pester full-suite and coverage baseline (P0-T18)

Timestamp: 2026-09-30T07-30 (artifact write time; the run itself began about 353 s earlier, per the junit `time` attribute)
Command: mcp__drm-copilot__run_poshqc_test with workspace_root = worktree root (no scan_folders)
EXIT_CODE: 1
MCP-Status: failure (tool result `"ok": false`, summary `Command exited with code 2.`; the stderr excerpt concerned MCP-server publish-verification notes for tag mcp-server-v0.0.2 and is unrelated to the tests below)
Output Summary:
- Counts read with the Read tool from artifacts/pester/pester-junit.xml (root `testsuites` element): tests 6094, failures 2, errors 0, disabled 10. Passed = 6094 - 2 - 10 = 6082 (total counted as 6094 including disabled). The file mtime is within the run window; the junit layout carries no `timestamp` attribute on `testsuites` or `testsuite`, so freshness rests on file mtime and the `time="353.212"` attribute matching the just-completed run.
- Names of every failed test (the exact set P5-T13 must reproduce):
  1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1, line 154: expected `allow`, got `deny`).
  2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` (tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1, line 165: `enforce-epic-wave-barrier.ps1` denied every admitted tool with `EPIC_WAVE_BARRIER_BLOCKED: '405' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint.`).
- Both failures are pre-existing at baseline and precede any edit by this plan. Both concern hook behavior driven by ambient checkpoint state in this worktree; neither touches the routing-contract module. This plan changes no PowerShell production file.
- Coverage read from artifacts/pester/powershell-coverage.xml with the Read tool (JaCoCo-style `counter` elements):
  - Source file `OrchestratorStateRoutingContract.psm1` (sourcefile element, lines 10204-10316): LINE missed=1, covered=106; line coverage = 106 / (106 + 1) = 99.07%.
  - Report-level LINE counter (line 17366): missed=416, covered=10688; line coverage = 10688 / (10688 + 416) = 10688 / 11104 = 96.25%.
- The PowerShell coverage figure was produced numerically; the `COVERAGE-UNMEASURED` disposition is not needed.
- Escalation: MCP status `failure` with two named baseline failures, recorded per the task; P5-T13 must reproduce this exact failed set.
