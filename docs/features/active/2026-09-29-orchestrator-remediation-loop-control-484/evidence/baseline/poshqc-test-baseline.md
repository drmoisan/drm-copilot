# Full Pester Gate Baseline (P0-T32)

Timestamp: 2026-10-01T21-21
Task: P0-T32

## Step 1 — MCP gate

Command: mcp__drm-copilot__run_poshqc_test (workspace_root: worktree root; scan_folders omitted, so the scan set comes from config/poshqc-scan.json)
ok: false
MCP summary: `Command exited with code 2.`
MCP stderr excerpt (first line): `Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. ...` (the excerpt is console output captured from the test run; it carries no counts)

## Step 2 — JUnit read

Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6, Pester 5.6.1)
Command: [xml]$j=Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $s=$j.testsuites; "Tests=$($s.tests) Failures=$($s.failures) Errors=$($s.errors)"; @($j.SelectNodes('//testcase[failure]') | ForEach-Object { $_.GetAttribute('name') })
JUnit file timestamp: written by this MCP run (modified 2026-10-01 21:21 UTC).

EXIT_CODE: 1

## Output Summary:

- MCP `ok`: false -> EXIT_CODE 1.
- tests: 6275
- failures: 2
- errors: 0
- Failing test-case names (one per line):

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

- Both failing tests concern hook surfaces (`.claude/hooks/` and Codex PreToolUse handlers), which are out of scope for this plan. This artifact is the comparison value for P10-T4.
- The 38 `OrchestratorStateIssueAdoption.Tests.ps1` failures observed in the folder-scoped P0-T30 run do not appear in this full-gate run.
