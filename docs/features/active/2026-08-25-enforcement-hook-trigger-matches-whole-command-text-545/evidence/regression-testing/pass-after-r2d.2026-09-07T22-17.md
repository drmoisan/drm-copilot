# Pass-after — R-2.d, the `cd`-chained read rule

Task: `[P4-T6]`
Timestamp: 2026-09-07T22-17

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1
ExpectedExitCode: 1

The MCP test runner exits with the folder-wide failed-test count. The count is 1: the single
tolerated pre-existing ambient failure in this folder. The three R-2.d failures recorded by
`[P4-T3]` are closed.

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session. Pester was run through
`mcp__drm-copilot__run_poshqc_test`, and per-suite and per-case results are read from
`artifacts/pester/pester-junit.xml`, never from the tool's exit code.

## The four R-2.d cases

| # | It name | Fail-before `status` (`[P4-T3]`) | Pass-after `status` |
|---|---|---|---|
| 1 | `R2d-C1 returns head for a cd-chained read inside a bash -c argument` | `Failed` | `Passed` |
| 2 | `R2d-C2 returns grep for a semicolon-chained read inside an sh -c argument` | `Failed` | `Passed` |
| 3 | `R2d-C3 returns cat for a cd-chained read inside a pwsh -Command argument` | `Failed` | `Passed` |
| 4 | `R2d-N1 still returns null for an echo whose quoted text contains a cd-then-read phrase` | `Passed` | `Passed` |

All four rows record `Passed`.

## The eight pre-existing `cd`-chain fixtures

Suite `tests/scripts/claude-hooks/validate-bash.Tests.ps1`, `Describe 'validate-bash.ps1'`,
`Context 'Get-CdChainedReadCommandMatch detects cd-chained read commands'`. The eight fixtures are
the `-TestCases` table at lines 164–171 of that suite, driven by the `It` named
`matches every read-command family chained after cd via '&&' or ';'`, which records `Passed`.

| # | Command fixture | Expected | `status` |
|---|---|---|---|
| 1 | `cd /tmp/x && grep -n test file.txt` | `grep` | `Passed` |
| 2 | `cd /tmp/x && cat file.txt` | `cat` | `Passed` |
| 3 | `cd /tmp/x; tail -f log.txt` | `tail` | `Passed` |
| 4 | `cd /tmp/x && head -20 file.txt` | `head` | `Passed` |
| 5 | `cd /tmp/x && less file.txt` | `less` | `Passed` |
| 6 | `cd /tmp/x && more file.txt` | `more` | `Passed` |
| 7 | `cd /tmp/x && awk "{print}" file.txt` | `awk` | `Passed` |
| 8 | `cd /tmp/x && sed -n 1,5p file.txt` | `sed -n` | `Passed` |

The remaining seven `It` rows of that Context also record `Passed`: `matches even when the chained
command's own path argument is absolute`, `returns $null for a bare read command with no preceding
cd`, `returns $null for a cd chained with a non-read-command (no false positive on common toolchain
invocations)`, `returns $null for empty or null input`, `produces a deny reason via
Get-BashBlockReason naming the matched read command`, `the dangerous-pattern denylist takes
precedence when a command matches both`, and `denies through Invoke-ValidateBashDecision for a
cd-chained read command in the nested tool_input`.

## The two pre-existing trigger-scoping `cd`-chain cases

Suite `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`,
`Context 'the cd-chained read-command leg'`.

| # | It name | `status` |
|---|---|---|
| 1 | `allows a commit message whose quoted text contains a cd-then-read phrase` | `Passed` |
| 2 | `still denies a read command that is not adjacent to the cd segment` | `Passed` |

Both preservation pins hold. The new regex leg is restricted to segments the scanner already reads
raw, so the masked commit-message case is untouched by it; the non-adjacent chain is still reported
by the retained `CommandWord` walk, which the edit left in place.

Ten of ten required rows record `Passed`. None blocks this phase.

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | 26 | 0 | 0 | 0 |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 16 | 0 | 0 | 0 |

`failures` and `errors` are 0 for both suites.

## Folder-wide totals and every failure named

| tests | failures | errors |
|---|---|---|
| 1545 | 1 | 0 |

| # | Suite | It name | Classification |
|---|---|---|---|
| 1 | `enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | tolerated row 1 — pre-existing ambient-state failure, not change-caused, not fixed here |

No other folder-wide failure.

## Output Summary

All four R-2.d cases pass. The eight pre-existing `cd`-chain fixtures and the two trigger-scoping
preservation pins all record `Passed`. Per-suite `failures` and `errors` are 0 for both
`validate-bash.Tests.ps1` and `validate-bash.TriggerScoping.Tests.ps1`. The folder-wide failure
count dropped from 4 to 1, and the single remaining failure is tolerated row 1.
