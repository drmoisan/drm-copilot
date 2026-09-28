# Baseline — Claude Hook Suite Pester Run (cycle 2)

Timestamp: 2026-09-07T21-00
Task: [P0-T6]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f scan_folders=["tests/scripts/claude-hooks"]
EXIT_CODE: 1
ExpectedExitCode: 1

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them,
so `Invoke-Pester` could not be called directly. The substitute route actually used is the MCP
runner `mcp__drm-copilot__run_poshqc_test`, with per-suite and per-case results read out of
`artifacts/pester/pester-junit.xml` rather than taken from the tool's return value. The MCP runner
exits with the folder-wide failed-test count, so its exit code cannot express per-suite acceptance;
the JUnit read-out is the authoritative source for every count below.

The MCP tool returned `{"ok": false, …, "summary": "Command exited with code 1."}`. Exit 1 equals the
folder-wide failed-test count of 1 and is the expected outcome, recorded as `ExpectedExitCode: 1`.

## Folder-wide totals

Read from the `<testsuites>` root element of `artifacts/pester/pester-junit.xml`:

| Metric | Value |
|---|---|
| suites | 65 |
| tests | 1525 |
| failures | 1 |
| errors | 0 |
| skipped | 0 (root reports `disabled="0"`; zero `status="Skipped"` testcases in the document) |
| time | 26.260 s |

## Per-suite rows for the five suites this cycle edits or depends on

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 9 | **0** | **0** |
| `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 3 | **0** | **0** |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 18 | **0** | **0** |
| `validate-bash.TriggerScoping.Tests.ps1` | 12 | **0** | **0** |
| `hook-command-scanner.Tests.ps1` | 42 | **0** | **0** |

All five record `failures` 0 and `errors` 0, as the acceptance condition requires.

The `hook-command-scanner.Tests.ps1` baseline of **42 tests, 0 failures** is the figure `[P1-T3]`
and `[P1-T7]` compare against on the Claude side: `[P1-T3]` must show `failures` exactly 5 higher
(that is, 5), and `[P1-T7]` must show `tests` exactly 5 higher (that is, 47) with `failures` back
to 0.

## Folder-wide failures, named by suite and `It`

Exactly one failure, extracted from the JUnit `testcase` carrying `status="Failed"`:

| # | Suite | `It` name |
|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` |

Full JUnit case name: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.

This is **row 1 of the plan's tolerated-failures table**, matched by name. No other folder-wide
failure exists, so every failure in this baseline is accounted for by the tolerated set. The cause
is ambient gitignored checkpoint state in this worktree (`artifacts/orchestration/orchestrator-state.json`
carries `"epic_mode": true` and the fixture command carries no `--base`), independently confirmed
not change-caused by the cycle-1 exit audit and filed as follow-up F-4. This cycle does not attempt
to fix it.

## Output Summary

65 suites, 1525 cases, 1 failure, 0 errors, 0 skipped. The single failure is the tolerated
`enforce-pr-author-skill.Tests.ps1` case named above — row 1 of the tolerated table — and no
untolerated failure exists. All five suites this cycle edits or depends on are green at baseline
with `failures` 0 and `errors` 0. Exit code 1 equals the folder-wide failed-test count and is the
declared expected value.
