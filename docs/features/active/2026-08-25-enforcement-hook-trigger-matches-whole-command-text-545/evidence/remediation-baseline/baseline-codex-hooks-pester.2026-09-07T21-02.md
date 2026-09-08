# Baseline — Codex Hook Suite Pester Run (cycle 2)

Timestamp: 2026-09-07T21-02
Task: [P0-T7]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f scan_folders=["tests/scripts/codex-hooks"]
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
| suites | 34 |
| tests | 856 |
| failures | 1 |
| errors | 0 |
| skipped | 0 (root reports `disabled="0"`; zero `status="Skipped"` testcases in the document) |
| time | 84.010 s |

## Per-suite rows for the four required suites

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 5 | **0** | **0** |
| `hook-command-scanner.Tests.ps1` | 41 | **0** | **0** |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | **0** |
| `enforce-epic-merge-gate-decision-surface.Tests.ps1` | 13 | **0** | **0** |

All four record `failures` 0 and `errors` 0, as the acceptance condition requires.

The `hook-command-scanner.Tests.ps1` baseline of **41 tests, 0 failures** is the figure `[P1-T3]`
and `[P1-T7]` compare against on the Codex side: `[P1-T3]` must show `failures` exactly 5 higher
(that is, 5), and `[P1-T7]` must show `tests` exactly 5 higher (that is, 46) with `failures` back
to 0.

The Codex scanner suite carries one case fewer than the Claude copy (41 against 42). That is a
pre-existing difference in the two suites, not a defect: the Claude file carries a
`Context 'D12 public parser contract'` that the Codex file does not, which is the same asymmetry the
plan records in `[P1-T2]` when it directs the new Context to a different insertion point on each
side. The two production scanner files remain byte-identical; only the suites differ.

## Folder-wide failures, named by suite and `It`

Exactly one failure, extracted from the JUnit `testcase` carrying `status="Failed"`:

| # | Suite | `It` name |
|---|---|---|
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` |

Full JUnit case name: `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`.

This is **row 2 of the plan's tolerated-failures table**, matched by name. No other folder-wide
failure exists, so every failure in this baseline is accounted for by the tolerated set. The cause
is this worktree's gitignored epic checkpoint state, which makes `enforce-epic-wave-barrier.ps1`
deny with `EPIC_WAVE_BARRIER_BLOCKED`; neither that hook nor that test file is in the branch diff,
and the cycle-1 exit audit independently confirmed the failure is not change-caused. This cycle
does not attempt to fix it.

## Output Summary

34 suites, 856 cases, 1 failure, 0 errors, 0 skipped. The single failure is the tolerated
`codex-pretooluse-integration.Tests.ps1` case named above — row 2 of the tolerated table — and no
untolerated failure exists. All four required suites are green at baseline with `failures` 0 and
`errors` 0. Exit code 1 equals the folder-wide failed-test count and is the declared expected value.
