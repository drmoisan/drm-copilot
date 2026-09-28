# Fail-Before — R-2 raw-scan predicate cases (ten, five per side)

Timestamp: 2026-09-07T21-14
Task: [P1-T3] `[expect-fail]`
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]
EXIT_CODE: 12
ExpectedExitCode: 12

A non-zero exit is the expected outcome of this task. The ten cases added by `[P1-T2]` call
`Test-CommandLineSegmentRawScan`, which Edit 1 has not yet introduced, so every one of them must
fail here. `ExpectedExitCode: 12` is the folder-wide failed-test count this artifact records: the
two tolerated pre-existing failures plus the ten new cases.

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them,
so `Invoke-Pester` could not be called directly. The substitute route actually used is the MCP
runner `mcp__drm-copilot__run_poshqc_test` over both hook-test folders in one invocation, with
per-case `status` attributes and per-suite counts read out of `artifacts/pester/pester-junit.xml`.
The MCP runner exits with the folder-wide failed-test count and reports no per-case detail, so the
JUnit read-out is the authoritative source for every row below. No stage was skipped.

## Folder-wide totals

| Metric | Value |
|---|---|
| tests | 2391 |
| failures | 12 |
| errors | 0 |
| skipped | 0 |
| time | 110.281 s |

## The ten new cases — all non-passing

Each row is one new `It` name per side, with the `status` attribute read from its `<testcase>`
element. Ten non-passing rows are required; ten are recorded.

| # | Side | `It` name | status |
|---|---|---|---|
| 1 | Claude | `R2-P1 reports true for a wrapper-led segment` | **Failed** |
| 2 | Claude | `R2-P2 reports true for a segment carrying a live substitution` | **Failed** |
| 3 | Claude | `R2-P3 reports true for an unbalanced segment` | **Failed** |
| 4 | Claude | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | **Failed** |
| 5 | Claude | `R2-P5 reports false for a null segment` | **Failed** |
| 6 | Codex | `R2-P1 reports true for a wrapper-led segment` | **Failed** |
| 7 | Codex | `R2-P2 reports true for a segment carrying a live substitution` | **Failed** |
| 8 | Codex | `R2-P3 reports true for an unbalanced segment` | **Failed** |
| 9 | Codex | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | **Failed** |
| 10 | Codex | `R2-P5 reports false for a null segment` | **Failed** |

Zero rows record `passed`. The required count of ten non-passing rows is met exactly; nine would
have failed this task.

### Failure reason, verbatim from the JUnit `<failure message>`

```
CommandNotFoundException: The term 'Test-CommandLineSegmentRawScan' is not recognized as a name of a
cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try
again.
```

The same message appears on all ten rows on both sides. This is the correct fail-before reason: the
cases fail because the predicate does not yet exist, not because a fixture or an assertion is
misstated. `assertions="0"` on each testcase confirms no assertion was reached.

## Per-suite `failures` against the `[P0-T6]` / `[P0-T7]` baselines

| Side | Suite | baseline `tests` | now `tests` | baseline `failures` | now `failures` | delta |
|---|---|---|---|---|---|---|
| Claude | `hook-command-scanner.Tests.ps1` | 42 | 47 | 0 | **5** | +5 |
| Codex | `hook-command-scanner.Tests.ps1` | 41 | 46 | 0 | **5** | +5 |

Both sides record `failures` exactly 5 higher than the `[P0-T6]` and `[P0-T7]` baselines, as the
acceptance condition requires. `errors` is 0 on both suites, so the ten failures are assertion-path
failures within the suites rather than suite-level load errors.

## The two remaining folder-wide failures are the tolerated pair

| # | Suite | `It` name |
|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` |

12 folder-wide failures = 10 new cases + these 2. No untolerated failure exists, so the ten new
failures are the only change from baseline and nothing else regressed when the suites were edited.

## Output Summary

Exit 12, equal to the folder-wide failed-test count and declared as the expected value. 2391 cases,
12 failures, 0 errors, 0 skipped. All ten new cases record `status="Failed"` with the
`CommandNotFoundException` for `Test-CommandLineSegmentRawScan`, which is the intended fail-before
reason. Per-suite `failures` for `hook-command-scanner.Tests.ps1` is 5 on each side, exactly 5 above
each baseline. The only other failures are the two tolerated pre-existing cases named above.
