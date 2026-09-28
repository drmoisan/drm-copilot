# Pass-After Regression Run — Epic Gate Manifest Branch

Timestamp: 2026-09-08T03-45

Task: [P3-T8]

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the branch worktree and **no
`scan_folders` argument**, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 2

ExpectedExitCode: 2

## Route

This gate asserts a named test outcome and a per-suite count rather than a coverage number, so it
does not need the new `CodeCoverage.Path` entry honored and the MCP runner is the valid route. The
self-hosted PoshQC invocation cannot run in this worktree at all, because the runtime
worktree-isolation guard refuses every `pwsh` invocation issued here.

The `testsuite` element read below is the one written by **this task's** run. The
`artifacts/pester/pester-junit.xml` on disk when this task began recorded the P2-T4 fail-before
state, so the suite was re-run before any figure was derived.

## Named test outcome

`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, node
`enforce-epic-worktree-removal-gate.ps1 manifest branch` >
`allows removal when a fresh manifest record authorizes the target`.

```xml
<testcase name="enforce-epic-worktree-removal-gate.ps1 manifest branch.allows removal when a fresh manifest record authorizes the target" status="Passed"
```

The same node was observed `Failed` with an observed decision of `deny` on the P2-T4 fail-before run
recorded at `evidence/regression-testing/fail-before-manifest-allow.2026-09-06T23-09.md`. The pair
is the fail-before / pass-after evidence AC-01 requires.

## Per-suite counts

The `testsuite` element whose `name` attribute ends with
`enforce-epic-worktree-removal-gate.Tests.ps1`, complete start tag transcribed verbatim:

```xml
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" tests="48" errors="0" failures="0" hostname="MEGALODON4" id="12" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5a6952a0a1e65c6e\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1" time="0.724">
```

The element carries no `passed` attribute, and the console output the module composes carries one
totals line and no per-suite breakdown, so the passed count is derived by the subtraction rule in
the plan's toolchain preamble: `tests` minus every non-passing count the element carries.

- Failed (read directly): **0**
- Passed (derived): 48 - 0 - 0 - 0 - 0 = **48**

## Whole-run totals

Root `testsuites` start tag, transcribed verbatim:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4374" errors="0" failures="2" disabled="9" time="152.547">
```

Passed (derived): 4374 - 2 - 0 - 9 = 4363.

## Failing-node inventory (2 of 2)

| # | Suite file | Node name | Classification |
| --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `enforce-pr-author-skill.ps1` > `allowed commands` > `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | Known-Local-Red Inventory member 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` > `allows every registered handler for every tool name its own matcher admits` | Known-Local-Red Inventory member 2 |

The observed `EXIT_CODE` of 2 equals the number of failing nodes this artifact names. That set is
exactly the two-member Known-Local-Red Inventory and no other test failed. The two Phase 2
expect-fail tests are now passing, so the failed count fell from 4 to 2.

## Toolchain steps preceding this run

| Step | Command | Result |
| --- | --- | --- |
| Format | `mcp__drm-copilot__run_poshqc_format` | `ok: true`; exit status 0. The anchored `--numstat` over `.claude/hooks` and `tests/scripts/claude-hooks` reported zero deleted lines on all four changed files afterwards, so the formatter rewrote nothing. |
| Analyze | `mcp__drm-copilot__run_poshqc_analyze` | `ok: true`; exit status 0. No findings. |
| Test | `mcp__drm-copilot__run_poshqc_test` | exit status 2, recorded above as this artifact's `EXIT_CODE`. |

Each per-step status is transcribed in a form whose text before the first colon is not exactly
`EXIT_CODE`. This file carries exactly one line whose pre-colon text is exactly `EXIT_CODE`, the
`EXIT_CODE: 2` row above, matched by its `ExpectedExitCode: 2` declaration.

Output Summary: `It 'allows removal when a fresh manifest record authorizes the target'` in the epic
gate suite now passes, having failed with an observed `deny` on the P2-T4 run. The suite reports 48
tests, 0 failures, 48 passed derived from the transcribed start tag. Whole run: 4363 passed, 2
failed, 9 skipped, exit code 2. The failing set is exactly the two-member Known-Local-Red Inventory
and no other test fails. Satisfies AC-01.
