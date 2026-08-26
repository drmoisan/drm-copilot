# Baseline — PoshQC Format (issue #516)

Timestamp: 2026-08-24T15-11
Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and **no** `scan_folders` argument (full configured scan set)
EXIT_CODE: 0

## Raw Result

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Ran bundled PoshQC format against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e'."}
```

## Files Rewritten by This Run

**None.** The run rewrote zero files.

Verification command run immediately after the format run:

```text
git status --porcelain --untracked-files=all
 M docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md
?? docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/evidence/baseline/baseline-branch-and-fileset.2026-08-23T23-25.md
?? docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/evidence/other/phase0-instructions-read.2026-08-23T23-25.md
```

The single modified tracked file is the plan document itself, modified by this executor's own [P0-T1] through [P0-T7] checkbox ticks. It is a Markdown file, is outside the PowerShell scan set, and was not touched by the formatter. The two untracked entries are Phase 0 evidence artifacts written by [P0-T6] and [P0-T7]. **No PowerShell file, and no tracked file of any kind, was rewritten by the formatter.**

## PRE-EXISTING FORMATTER DRIFT

None. The baseline format run rewrote no tracked file, so no `git checkout --` restoration was required and this heading names zero paths. [P4-T1] must therefore find its own drift set to be a subset of the empty set — that is, [P4-T1] must record no drift at all.

Output Summary: Baseline PoshQC format completed successfully over the full configured scan set with `ok: true`, EXIT_CODE 0. Zero files were rewritten. `git status --porcelain` after the run reports no modified tracked file other than the plan document, whose modification is this executor's own checkbox bookkeeping and not a formatter rewrite. No pre-existing formatter drift exists in this worktree.
