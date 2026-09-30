# Full Pester Gate Final QA (P10-T4)

Timestamp: 2026-09-30T15-18
Command: mcp__drm-copilot__run_poshqc_test (workspace_root: the worktree root; no scan_folders), then JUnit read: [xml]$j=Get-Content -Raw -LiteralPath artifacts/pester/pester-junit.xml; $s=$j.testsuites; "Tests=$($s.tests) Failures=$($s.failures) Errors=$($s.errors)"; @($j.SelectNodes('//testcase[failure]') | ForEach-Object { $_.GetAttribute('name') }), then the P10-T4 literal-name read
ok: false
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: MCP result `ok:false` (summary `Command exited with code 3.`). JUnit `testsuites`: Tests=6201 Failures=3 Errors=0. ACCEPTANCE NOT MET: one failing test case is not in the P0-T26 pre-existing set (new failure listed below). The three literal-name lines each print `Count=1 Failed=0`.

Execution route: MCP tool call, then the JUnit reads through the PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command '<command text>'`, run with `sh`). The JUnit file `artifacts/pester/pester-junit.xml` was written by this run (modification time 15:18 UTC, after the MCP call started).

MCP ok: false
Tests: 6201
Failures: 3
Errors: 0

## Failing test-case names (verbatim from the JUnit `name` attribute)

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
enforcement hooks supply the checkpoint path explicitly.the orchestrator-state module keeps its four hundred ninety-nine line count
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Comparison with the P0-T26 set:

- In P0-T26 set, still failing: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- In P0-T26 set, still failing: `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`
- P0-T26 failures that no longer fail: none
- NEW failure (not in P0-T26 set): `enforcement hooks supply the checkpoint path explicitly.the orchestrator-state module keeps its four hundred ninety-nine line count`

## Literal-name lines

```
discovers exactly nine back-compat fixtures Count=1 Failed=0
publishes the vocabulary as none plus both partitions Count=1 Failed=0
discovers at least the minimum corpus count Count=1 Failed=0
```

## Diagnosis of the new failure

- Test: `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, It `the orchestrator-state module keeps its four hundred ninety-nine line count` (line 153). Assertion: `@(Get-Content -LiteralPath .claude/lib/orchestrator-state/OrchestratorState.psm1).Count | Should -Be 499`. The test was added by the #673 change set (commit 1329b43e) to pin the module as unmodified by that change set.
- Observed: current line count 492. `git diff --numstat origin/epic/orchestrator-state-contract-correctness-integration -- .claude/lib/orchestrator-state/OrchestratorState.psm1` prints `6	13`, so the base count is 492 + 13 - 6 = 499. The test passed at P0-T26 and fails because of this branch's intended Phase 5 edit to the module (the `VALID_BLOCKED_REASONS` / partition constants and the `-cnotcontains` / `-cne` operators).
- The plan did not anticipate this test; it is not in the P0-T26 set and no plan task edits it. Making it pass requires editing a test file outside the plan's authored-file set (the pinned value, or the pin itself), which is a scope decision returned to the orchestrator. The check was not weakened and the test was not modified.
