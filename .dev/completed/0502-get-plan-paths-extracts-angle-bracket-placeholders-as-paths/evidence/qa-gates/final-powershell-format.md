# QA Gate — Final PowerShell Formatting — [P8-T6]

Timestamp: 2026-08-23T05-20

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T6]
Run: revision-6 re-run.

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root,
bracketed by two captures of `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`.

EXIT_CODE: 0

Tool return, verbatim:

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50","summary":"Ran bundled PoshQC format against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50'."}
```

The tool reports `ok: true`.

## Before snapshot, verbatim

```text
M  tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
```

## After snapshot, verbatim

```text
M  tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
```

## The two snapshots are byte-identical

One entry in each, same path, same index status code. **PASS.**

The snapshot is a single entry on this run rather than the nine of the previous run, and the reason is
the commit: the eight created paths and the earlier module edits are now in `fd20019d`, so the only
PowerShell-family path with uncommitted work is the normalization test file [P5-T3] just edited. That
entry carries the staged status `M ` because [P5-T5] ran `git add -A` immediately before this task. It
is pre-existing state relative to *this command* and it appears identically in both snapshots, so it
cancels — which is exactly what the paired form is for.

## Why the pair replaces a bare zero-files-changed reading

This is a write-mode formatter. Its return value carries only an ok flag, a tool name, a workspace
root, and a one-sentence summary; it names no file it rewrote and reports no count. Its exit status is
0 whether or not it rewrote a file, so the exit code alone cannot observe a reformat, and a single
post-hoc snapshot compares worktree to index and cannot attribute a modification to the command that
just ran.

Two snapshots around the single invocation make the observation run-scoped. A rewrite from this run
would appear only in the after snapshot, as a worktree-modified flag alongside the staged one —
`M ` becoming `MM` — while state already present appears in both and cancels. The entry did not
change, so the formatter rewrote no PowerShell file, including the file [P5-T3] had just edited by
hand.

The pathspec is extension-based so it covers every file the formatter can write without depending on
the formatter's own scan configuration.

## Restart-clause status

The snapshots are identical, so the formatting stage changed no PowerShell file and the Phase 8
restart clause is not triggered by this task.

## Output Summary

The tool reports ok. The before and after snapshots are byte-identical, so the PowerShell formatting
stage rewrote nothing. The paired observation is what establishes this, since the tool's own return
value cannot.
