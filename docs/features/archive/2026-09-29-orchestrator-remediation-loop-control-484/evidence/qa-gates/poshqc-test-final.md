# Full Pester Gate Final via Policy Route (P10-T4)

Timestamp: 2026-10-01T22-54
Task: P10-T4
Loop iteration: 2

## Step 1 — MCP gate

Command: mcp__drm-copilot__run_poshqc_test (workspace_root: worktree root; scan_folders omitted, so the scan set comes from config/poshqc-scan.json)
ok: false
MCP summary: `Command exited with code 2.`
MCP stderr excerpt (first line): `Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. ...` (console output from a test run; it carries no counts)

## Step 2 — JUnit reads

Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6, Pester 5.6.1)
JUnit file: `artifacts/pester/pester-junit.xml`, last written 2026-10-01T22:54:33Z by this MCP run.

Command (P0-T32 read): [xml]$j=Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $s=$j.testsuites; "Tests=$($s.tests) Failures=$($s.failures) Errors=$($s.errors)"; @($j.SelectNodes('//testcase[failure]') | ForEach-Object { $_.GetAttribute('name') })

Command (literal names): [xml]$j=Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; foreach ($t in @('discovers exactly eleven remediation back-compat fixtures','discovers at least the minimum remediation corpus count','keeps every non-remediable class inside the blocked-reason non-mechanical partition','validates a halt checkpoint without cycles cleanly')) { $c=@($j.SelectNodes('//testcase') | Where-Object { $_.GetAttribute('name').EndsWith('.' + $t) }); "$t Count=$($c.Count) Failed=$(@($c | Where-Object { $_.SelectSingleNode('failure') }).Count)" }

EXIT_CODE: 1
ExpectedExitCode: 1

## Output Summary:

- MCP `ok`: false -> EXIT_CODE 1. The failing set is non-empty -> ExpectedExitCode 1.
- tests: 6488 (P0-T32: 6275)
- failures: 2
- errors: 0
- Failing test-case names:

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

- Both names are in the P0-T32 failing set, which holds exactly these two names; no new failure and no P0-T32 member stopped failing.
- Literal-name lines:

```
discovers exactly eleven remediation back-compat fixtures Count=1 Failed=0
discovers at least the minimum remediation corpus count Count=1 Failed=0
keeps every non-remediable class inside the blocked-reason non-mechanical partition Count=1 Failed=0
validates a halt checkpoint without cycles cleanly Count=1 Failed=0
```

- Result: PASS under the baseline-identity rule.
