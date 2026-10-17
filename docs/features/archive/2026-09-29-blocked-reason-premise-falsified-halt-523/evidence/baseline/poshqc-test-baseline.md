# Full Pester Gate Baseline (P0-T26)

Timestamp: 2026-09-30T14-26
Command: mcp__drm-copilot__run_poshqc_test (workspace_root: the worktree root; no scan_folders), then JUnit read: [xml]$j=Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $s=$j.testsuites; "Tests=$($s.tests) Failures=$($s.failures) Errors=$($s.errors)"; @($j.SelectNodes('//testcase[failure]') | ForEach-Object { $_.GetAttribute('name') })
EXIT_CODE: 1
Output Summary: MCP result `ok:false` (summary `Command exited with code 2.`). JUnit `testsuites`: Tests=6109 Failures=2 Errors=0. Two failing test cases (listed below).

MCP ok: false
Tests: 6109
Failures: 2
Errors: 0

Failing test-case names (one per line, verbatim from the JUnit `name` attribute):

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Execution route: MCP tool call, then the JUnit read through the PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`). The JUnit file `artifacts/pester/pester-junit.xml` was written by this run (modification time after the MCP call started).

Deviation from the orchestrator's pre-plan observation (5587 tests, 1 failure, 0 errors): this run observed 6109 tests and 2 failures. The Codex PreToolUse handler case matches the pre-plan observation; the `enforce-pr-author-skill.ps1` case is an additional pre-existing failure on the unmodified tree (no production or test file had been changed when this ran). Both failures are pre-existing baseline state and are the comparison value for P10-T4.

The MCP `stderr_excerpt` contained publish-verification messages (tag `mcp-server-v0.0.2` returning `NO_RUN`, `STEP_SKIPPED`, `UNRESOLVED`); these are output emitted by tests exercising the publish verifier, not tool failures.
