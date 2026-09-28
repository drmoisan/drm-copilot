# Batch B toolchain gate — [P2-T9]

Timestamp: 2026-09-07T21-49

Task: `[P2-T9]` — run the batch-B toolchain gate with the `[P1-T8]` procedure: format, then
analyze, then the two hook-test folders, in that order, restarting from format if any stage
fails or rewrites a file.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session, so
no PoshQC stage was run as a direct shell command. The substitute route for every stage is the
bundled MCP function set: `mcp__drm-copilot__run_poshqc_format`,
`mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, all with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`.
Per-suite and per-case test results are read from `artifacts/pester/pester-junit.xml` rather
than from the test runner's exit code, because that runner exits with the folder-wide failed
count and both folders carry one pre-existing tolerated failure.

EXIT_CODE: 0 for the format and analyze stages. The two test stages each exited 1, which is the
folder-wide failed-test count and equals the one tolerated failure in each folder.

---

## Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and no `scan_folders` argument.

EXIT_CODE: 0 (`ok: true`)

The formatter exits 0 whether or not it rewrote a file, so the exit code alone gates nothing.
Two independent observations establish that it rewrote nothing.

### Observation 1 — `git status --porcelain` before and after

Command: `git status --porcelain | sort` immediately before and immediately after the
formatter, compared with `comm -13`.

**Set-difference count (paths present after and absent before): 0.**

The before capture, verbatim (13 modified tracked files plus 20 untracked evidence artifacts):

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
 M .claude/hooks/hook-command-scanner.ps1
 M .codex/hooks/enforce-epic-merge-gate.ps1
 M .codex/hooks/hook-command-scanner.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
 M tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
 M tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
 M tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
 M tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
```

plus the untracked evidence artifacts under the feature folder's `evidence/` tree.

The after capture is identical: `comm -13` over the two sorted captures produced no lines, so
the count is 0 and the formatter introduced no newly modified path.

### Observation 2 — SHA-256 of the four merge-gate copies, before and after

| File | Before | After |
|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` |
| `extensions/…/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` |
| `extensions/…/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` |

All four digests are unchanged across the formatter run, and each canonical file still equals
its mirror, so `[P2-T7]`'s parity result survives the format stage.

## Stage 2 — Analyze

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and no
`scan_folders` argument.

EXIT_CODE: 0

Result value: **`ok: true`**. That is the value the analyzer prints on a clean run; it reports
no diagnostic count, so `ok: true` is the value asserted.

## Stage 3 — Tests, Claude hook folder

Command: `mcp__drm-copilot__run_poshqc_test` with
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

ExpectedExitCode: 1

Folder totals: `tests=1533 failures=1 errors=0 skipped=0`.

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 | 0 | 0 |
| `enforce-epic-merge-gate.Tests.ps1` | 56 | 0 | 0 |

The single folder-wide failure is
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` It
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, which is
tolerated row 1. There is no other failure in the folder.

## Stage 4 — Tests, Codex hook folder

Command: `mcp__drm-copilot__run_poshqc_test` with
`scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

ExpectedExitCode: 1

Folder totals: `tests=863 failures=1 errors=0 skipped=0`.

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 7 | 0 | 0 |
| `enforce-epic-merge-gate-decision-surface.Tests.ps1` | 13 | 0 | 0 |

The single folder-wide failure is
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` It
`allows every registered handler for every tool name its own matcher admits`, which is tolerated
row 2. There is no other failure in the folder.

## `wc -l` inventory — four merge-gate copies and two edited suites

| File | `wc -l` | At or under 500 |
|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 486 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 486 | yes |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 186 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 186 | yes |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 174 | yes |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 106 | yes |

## Output Summary

All four stages passed on the first attempt. **No restart from stage 1 was required; the
restart count is 0.** Format rewrote nothing, evidenced by a porcelain set-difference count of
0 and four unchanged SHA-256 digests rather than by its exit code alone. Analyze reported
`ok: true`. Both test folders report `errors` 0 and exactly one failure each, and both failures
are the named tolerated rows: `allows gh pr create --body-file artifacts/pr_body_12.md when
context exists` on the Claude side and `allows every registered handler for every tool name its
own matcher admits` on the Codex side. Neither edited merge-gate suite carries a failure. All
six inventoried files are at or under 500 lines.
