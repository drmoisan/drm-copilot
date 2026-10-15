# Full Pester Gate Final QA (P10-T4)

Timestamp: 2026-09-30T15-52
Command: mcp__drm-copilot__run_poshqc_test (workspace_root: the worktree root; no scan_folders), then JUnit read: [xml]$j=Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $s=$j.testsuites; "Tests=$($s.tests) Failures=$($s.failures) Errors=$($s.errors)"; @($j.SelectNodes('//testcase[failure]') | ForEach-Object { $_.GetAttribute('name') }), then the P10-T4 literal-name read
ok: false
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: MCP result `ok:false` (summary `Command exited with code 2.`). JUnit `testsuites`: Tests=6201 Failures=2 Errors=0. Both failing test cases are in the P0-T26 set; no new failure. The three literal-name lines each print `Count=1 Failed=0`. The #523 cap row `the orchestrator-state module stays within the 500-line file cap` ran and passed (`Count=1 Failed=0`). Loop iteration 2 (restart after remediation cycle 1; supersedes the iteration 1 artifact).

Execution route: MCP tool call, then the JUnit reads through the PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`). The JUnit file `artifacts/pester/pester-junit.xml` was written by this run (modification time 15:52 UTC, after the MCP call started at 15:46 UTC).

MCP ok: false
Tests: 6201
Failures: 2
Errors: 0

## Failing test-case names (verbatim from the JUnit `name` attribute)

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Comparison with the P0-T26 set (`evidence/baseline/poshqc-test-baseline.md`):

- In P0-T26 set, still failing: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- In P0-T26 set, still failing: `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`
- P0-T26 failures that no longer fail: none
- New failures (not in P0-T26 set): none

## Literal-name lines

```
discovers exactly nine back-compat fixtures Count=1 Failed=0
publishes the vocabulary as none plus both partitions Count=1 Failed=0
discovers at least the minimum corpus count Count=1 Failed=0
```

## Remediation cycle 1 cap row (informational, not a plan-mandated line)

```
cap Count=1 Failed=0
```

(`enforcement hooks supply the checkpoint path explicitly.the orchestrator-state module stays within the 500-line file cap`; the iteration 1 failure of the former `four hundred ninety-nine line count` row is resolved by remediation cycle 1, commit df9bddd5.)

The MCP `stderr_excerpt` contained publish-verification messages (tag `mcp-server-v0.0.2` returning `NO_RUN`, `STEP_SKIPPED`, `UNRESOLVED`); as at P0-T26, these are output emitted by tests exercising the publish verifier, not tool failures.
