# Batch A — Toolchain Gate (format, analyze, both hook-test folders)

Timestamp: 2026-09-07T21-27
Task: [P1-T8]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

EXIT_CODE: 0 (gate result; per-stage exit codes are recorded individually below)

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them.
Every stage below was reached through the MCP route: `mcp__drm-copilot__run_poshqc_format`,
`mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, with per-suite and
per-case results read out of `artifacts/pester/pester-junit.xml` rather than taken from the tool's
exit code. No stage was skipped. PowerShell has no type-check stage, so the loop is format, then
lint, then test.

## Stage 1 — Format

Command: mcp__drm-copilot__run_poshqc_format workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f
EXIT_CODE: 0

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f'."}
```

The formatter exits 0 whether or not it rewrote a file, so the exit code alone gates nothing. The
two observations below are what establish that it rewrote nothing.

### `git status --porcelain` — before

```
 M .claude/hooks/hook-command-scanner.ps1
 M .codex/hooks/hook-command-scanner.ps1
 M docs/features/active/2026-08-25-...-545/remediation-plan.2026-09-07T20-45.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
 M tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
 M tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
?? docs/.../evidence/qa-gates/batch-a-budget-reset.2026-09-07T21-10.md
?? docs/.../evidence/qa-gates/batch-a-parity.2026-09-07T21-18.md
?? docs/.../evidence/regression-testing/fail-before-r2-predicate.2026-09-07T21-14.md
?? docs/.../evidence/regression-testing/pass-after-r2-predicate.2026-09-07T21-20.md
?? docs/.../evidence/remediation-baseline/baseline-claude-hooks-pester.2026-09-07T21-00.md
?? docs/.../evidence/remediation-baseline/baseline-codex-hooks-pester.2026-09-07T21-02.md
?? docs/.../evidence/remediation-baseline/baseline-failclosed-call-sites.2026-09-07T21-07.md
?? docs/.../evidence/remediation-baseline/baseline-git-state.2026-09-07T20-55.md
?? docs/.../evidence/remediation-baseline/baseline-line-counts.2026-09-07T21-09.md
?? docs/.../evidence/remediation-baseline/baseline-per-file-coverage.2026-09-07T21-05.md
?? docs/.../evidence/remediation-baseline/baseline-poshqc-analyze.2026-09-07T20-57.md
?? docs/.../evidence/remediation-baseline/baseline-poshqc-format.2026-09-07T20-56.md
?? docs/.../evidence/remediation-baseline/baseline-python-contracts.2026-09-07T21-04.md
?? docs/.../evidence/remediation-baseline/phase0-instructions-read.2026-09-07T20-52.md
?? docs/.../evidence/remediation-baseline/phase0-remediation-documents-read.2026-09-07T20-54.md
```

23 entries. The seven tracked-modified entries are exactly the four scanner copies (two canonical,
two bundle mirrors), the two scanner test suites, and the plan file. The sixteen untracked entries
are this cycle's evidence artifacts. The `docs/.../` elision shortens the common prefix
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`; every
path is otherwise verbatim.

### `git status --porcelain` — after

Byte-identical to the before capture. `diff <sorted-before> <sorted-after>` exits 0 with no output.

### Set-difference count

Computed with `comm -13 <sorted-before> <sorted-after>` — paths present after and absent before:

```
(no output)
```

**Set-difference count: 0.** The formatter created no untracked file and dirtied no additional
tracked file.

### SHA-256 of the four scanner copies, before and after

All four values are `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` both before
and after the formatter run.

| File | Before | After |
|---|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | `d8543cb9…add0b` | `d8543cb9…add0b` |
| `extensions/…/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | `d8543cb9…add0b` | `d8543cb9…add0b` |
| `.codex/hooks/hook-command-scanner.ps1` | `d8543cb9…add0b` | `d8543cb9…add0b` |
| `extensions/…/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | `d8543cb9…add0b` | `d8543cb9…add0b` |

All four hashes are **unchanged** across the formatter run, and all four remain equal to each other,
so copy-set parity survived the format stage. Edit 1's text is already formatter-clean.

## Stage 2 — Analyze

Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f
EXIT_CODE: 0

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f'."}
```

Literal asserted value: **`ok: true`**. The analyzer reports no diagnostic count on a clean run, so
`ok: true` is the value asserted, matching the `[P0-T5]` baseline. Edit 1 introduced no
PSScriptAnalyzer diagnostic; the new function carries `[CmdletBinding()]`, `[OutputType([bool])]`,
comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, and `.OUTPUTS`, and an approved
verb.

## Stage 3 — Tests, `tests/scripts/claude-hooks`

Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f scan_folders=["tests/scripts/claude-hooks"]
EXIT_CODE: 1
ExpectedExitCode: 1

| Metric | Baseline `[P0-T6]` | Now |
|---|---|---|
| tests | 1525 | **1530** (+5) |
| failures | 1 | **1** |
| errors | 0 | **0** |
| skipped | 0 | **0** |

Per-suite: `hook-command-scanner.Tests.ps1` records `tests="47" errors="0" failures="0"`, exactly
5 tests above its baseline of 42 with no failure.

**The only folder-wide failure is one of the two tolerated names:**
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` It
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (tolerated row 1).

## Stage 4 — Tests, `tests/scripts/codex-hooks`

Command: mcp__drm-copilot__run_poshqc_test workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f scan_folders=["tests/scripts/codex-hooks"]
EXIT_CODE: 1
ExpectedExitCode: 1

| Metric | Baseline `[P0-T7]` | Now |
|---|---|---|
| tests | 856 | **861** (+5) |
| failures | 1 | **1** |
| errors | 0 | **0** |
| skipped | 0 | **0** |

Per-suite: `hook-command-scanner.Tests.ps1` records `tests="46" errors="0" failures="0"`, exactly
5 tests above its baseline of 41 with no failure. `legacy-codex-hook-contracts.Tests.ps1` records
`tests="43" errors="0" failures="0"`; that is the suite asserting canonical/bundle byte-identity
parity and the 500-line cap for the shared modules, so both contracts hold after Edit 1.

**The only folder-wide failure is the other tolerated name:**
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` It
`allows every registered handler for every tool name its own matcher admits` (tolerated row 2).

Across both folders the failure set is exactly the two tolerated names and nothing else.

## `wc -l` for all four scanner copies

| File | Lines | At or under 500 |
|---|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | **483** | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | **483** | yes |
| `.codex/hooks/hook-command-scanner.ps1` | **483** | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | **483** | yes |

Each is at or under 500, with 17 lines of headroom. This is the `wc -l` observation `[P1-T4]` defers
to this task. The pre-edit count recorded by `[P0-T11]` was 450 per copy, so Edit 1 added 33 lines
to each.

## Output Summary

The batch-A toolchain gate passed in a single pass. **No restart from stage 1 was required, and the
restart count is 0.** Stage 1 (format) exited 0 with a porcelain set-difference of 0 and all four
scanner SHA-256 values unchanged, so no file was rewritten. Stage 2 (analyze) returned `ok: true`.
Stage 3 and stage 4 each exited with their folder's tolerated-failure count of 1; the Claude folder
reports 1530 tests / 1 failure / 0 errors and the Codex folder 861 / 1 / 0, each exactly 5 tests
above its Phase 0 baseline, with `hook-command-scanner.Tests.ps1` at 47/0/0 and 46/0/0 respectively.
The only failures across both folders are the two tolerated pre-existing cases. All four scanner
copies stand at 483 lines, under the 500-line cap.
