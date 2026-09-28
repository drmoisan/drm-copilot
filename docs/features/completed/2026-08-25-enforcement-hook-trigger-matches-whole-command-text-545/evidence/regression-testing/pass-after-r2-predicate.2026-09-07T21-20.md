# Pass-After — R-2 raw-scan predicate cases (ten, five per side)

Timestamp: 2026-09-07T21-20
Task: [P1-T7]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]
EXIT_CODE: 2
ExpectedExitCode: 2

Exit 2 equals the folder-wide failed-test count, which is the two tolerated pre-existing failures
and nothing else. It is the expected value once Edit 1 is applied: the run's exit code cannot reach
0 while those two ambient failures are present, which is why acceptance is stated on per-suite and
per-case JUnit values rather than on the exit code.

This is the same command as `[P1-T3]`, re-run after Edit 1 was applied to both canonical scanner
copies.

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them,
so `Invoke-Pester` could not be called directly. The substitute route actually used is the MCP
runner `mcp__drm-copilot__run_poshqc_test` over both hook-test folders in one invocation, with
per-case `status` attributes and per-suite counts read out of `artifacts/pester/pester-junit.xml`.
No stage was skipped.

## Folder-wide totals

| Metric | Value | `[P1-T3]` fail-before |
|---|---|---|
| tests | 2391 | 2391 |
| failures | **2** | 12 |
| errors | 0 | 0 |
| skipped | 0 | 0 |
| time | 108.298 s | 110.281 s |

Failures fell from 12 to 2. The ten that cleared are exactly the ten new cases.

## The ten new cases — all passing

| # | Side | `It` name | status |
|---|---|---|---|
| 1 | Claude | `R2-P1 reports true for a wrapper-led segment` | **Passed** |
| 2 | Claude | `R2-P2 reports true for a segment carrying a live substitution` | **Passed** |
| 3 | Claude | `R2-P3 reports true for an unbalanced segment` | **Passed** |
| 4 | Claude | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | **Passed** |
| 5 | Claude | `R2-P5 reports false for a null segment` | **Passed** |
| 6 | Codex | `R2-P1 reports true for a wrapper-led segment` | **Passed** |
| 7 | Codex | `R2-P2 reports true for a segment carrying a live substitution` | **Passed** |
| 8 | Codex | `R2-P3 reports true for an unbalanced segment` | **Passed** |
| 9 | Codex | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | **Passed** |
| 10 | Codex | `R2-P5 reports false for a null segment` | **Passed** |

Ten of ten record `status="Passed"`. Every row of the `[P1-T3]` fail-before table is now green.

The two negative cases are load-bearing and did not pass vacuously: `R2-P4` asserts `$false` for
`git commit -m "gh pr merge --merge 688"`, so a predicate that returned `$true` unconditionally
would fail it, and `R2-P5` asserts `$false` for a null segment, so a predicate that dereferenced
`$Segment` without the null guard would error there.

## Per-suite counts against the `[P0-T6]` / `[P0-T7]` baselines

| Side | Suite | baseline `tests` | now `tests` | delta | `failures` | `errors` |
|---|---|---|---|---|---|---|
| Claude | `hook-command-scanner.Tests.ps1` | 42 | **47** | **+5** | **0** | **0** |
| Codex | `hook-command-scanner.Tests.ps1` | 41 | **46** | **+5** | **0** | **0** |

Each side's `tests` count is exactly 5 higher than its baseline, and `failures` and `errors` are
both 0 on both sides, as the acceptance condition requires.

## Both folder-wide failure lists contain only the two tolerated names

| # | Suite | `It` name |
|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` |

These are rows 1 and 2 of the plan's tolerated-failures table, matched by name. No third failure
exists on either side, so no existing case regressed when Edit 1 was applied to the two production
scanner files.

## Output Summary

Exit 2, equal to the folder-wide failed-test count and declared as the expected value. 2391 cases,
2 failures, 0 errors, 0 skipped, down from 12 failures at fail-before. All ten new cases pass on
both sides. `hook-command-scanner.Tests.ps1` records 47 tests / 0 failures / 0 errors on the Claude
side and 46 / 0 / 0 on the Codex side, each exactly 5 tests above its baseline. The only remaining
failures are the two tolerated pre-existing cases.
