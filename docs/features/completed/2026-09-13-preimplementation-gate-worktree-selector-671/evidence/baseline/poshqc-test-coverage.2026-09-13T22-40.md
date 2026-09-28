# Baseline — PoshQC Test with Coverage (issue #671)

Timestamp: 2026-09-17T08-01
Task: [P0-T8]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root; coverage enabled by the runsettings) as the route-compliance step; then `[xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')` and `[xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml')` read by a scratchpad parser under pwsh 7.6.6 at the worktree root
EXIT_CODE: 2

Output Summary:
- MCP call disposition: non-zero. The tool returned `ok: false`, summary "Command exited with code 2.", with a stderr excerpt from a test's own output (publish-verification messages). `Run.Exit = $true`, so a run with failing tests exits non-zero; the reports below were written by this run (`pester-junit.xml` LastWriteTime 2026-09-17T08:00:21, `powershell-coverage.xml` LastWriteTime 2026-09-17T07:59:18; the `artifacts/pester/` directory did not exist before the run).
- JUnit root `testsuites`: tests=4547, failures=2, errors=0, disabled=9; passed = 4547 - 2 - 0 - 9 = 4536.
- Coverage report-level `counter type="LINE"`: covered=8914, missed=422; baseline line coverage = 8914 / 9336 = 95.48%.
- Per-file line coverage, `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (sourcefile under the package whose name ends with `.claude/hooks`): covered=112, missed=6, 94.92%.
- Per-file line coverage, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (package ending `.codex/hooks`): covered=112, missed=6, 94.92%.
- Package names are directory-qualified (absolute paths), so the disambiguation applies.

## Failing-node enumeration (count 2, equals `failures`)

| # | name | classname | status |
| --- | --- | --- | --- |
| 1 | `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686/tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | Failed |
| 2 | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` | `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686/tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | Failed |

Neither failing node belongs to a suite this plan edits. Both failures predate any change on this branch.

Testcase status census: Passed=4536, Failed=2, Skipped=9.
