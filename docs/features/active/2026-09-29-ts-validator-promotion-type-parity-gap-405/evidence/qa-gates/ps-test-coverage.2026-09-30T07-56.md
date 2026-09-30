# PowerShell full Pester suite and coverage final QA (P5-T13)

Timestamp: 2026-09-30T07-56 (artifact write time; the run began about 07:50 and the junit file was written 07:56:34)
Command: mcp__drm-copilot__run_poshqc_test with workspace_root = worktree root (no scan_folders)
EXIT_CODE: 1
MCP-Status: failure (tool result `"ok": false`, summary `Command exited with code 2.`; the stderr excerpt concerned MCP-server publish-verification notes for tag mcp-server-v0.0.2, identical to the P0-T18 baseline and unrelated to the tests below)
Output Summary:
- Counts read from artifacts/pester/pester-junit.xml (root `testsuites` element): tests 6109, failures 2, errors 0, disabled 10. Passed = 6109 - 2 - 10 = 6097. Total 6109.
- Baseline comparison (P0-T18): tests 6094, failures 2, disabled 10, passed 6082. Passed count 6097 equals 6082 plus 15. The total rose by 15, the number of new parity tests.
- Freshness: the junit layout carries no `timestamp` attribute; file mtime 2026-09-30 07:56:34 is after the run start, and root `time="374.280"` matches a just-completed full run.
- Names of every failed test (the exact set P0-T18 recorded; both are read from `<failure>` elements at junit lines 2258 and 7018):
  1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1, line 154: expected `allow`, got `deny`).
  2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` (tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1).
- The failed-test-name set equals the P0-T18 set exactly. No new failure. Both are pre-existing baseline failures unrelated to this change.
- Coverage read from artifacts/pester/powershell-coverage.xml (mtime 07:54:48, fresh):
  - `OrchestratorStateRoutingContract.psm1` (sourcefile element, lines 10204-10316): LINE missed=1, covered=106; line coverage = 106 / (106 + 1) = 99.07%.
  - Report-level LINE counter (line 17366): missed=416, covered=10688; line coverage = 10688 / (10688 + 416) = 10688 / 11104 = 96.25%.
- The PowerShell coverage figure was produced numerically; the `COVERAGE-UNMEASURED` disposition is not needed. There is no PowerShell branch-coverage gate.
