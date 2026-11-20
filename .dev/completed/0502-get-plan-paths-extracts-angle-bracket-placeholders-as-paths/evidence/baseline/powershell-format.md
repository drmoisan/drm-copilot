# Baseline — PowerShell Formatting — [P0-T6]

Timestamp: 2026-08-23T00-14

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T6]
State captured: PRE-CHANGE baseline

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root,
bracketed by two captures of `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`.

EXIT_CODE: 0

## Why a before-and-after snapshot pair

This is a write-mode formatter. Its return value carries only an ok flag, a tool name, a
workspace root, and a one-sentence summary; it names no file it rewrote and reports no count, so
its exit status cannot report whether it changed anything. A single post-hoc `git status` compares
the worktree against the index and therefore cannot attribute a modification to a particular
command. Two snapshots taken around the single invocation make the observation run-scoped: a
rewrite from this run appears only in the after snapshot, while drift already present appears in
both and cancels.

The pathspec is extension-based (`*.ps1`, `*.psm1`, `*.psd1`) so that it covers every file the
formatter can write without depending on the formatter's own scan configuration.

This task is a baseline capture with no threshold. The [P8-T6] counterpart uses the same method
with byte-identity of the two snapshots as its gate.

## Before snapshot, verbatim

```text
```

The before snapshot is empty. It is recorded verbatim as an empty block, per the acceptance
requirement that both snapshots be recorded even when empty.

## After snapshot, verbatim

```text
```

The after snapshot is also empty.

## Tool summary, verbatim

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50","summary":"Ran bundled PoshQC format against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50'."}
```

## Output Summary

Baseline PowerShell formatting is clean. The formatter reported ok. The before and after
snapshots are both empty and therefore byte-identical, so the formatter rewrote no PowerShell
file and the tree carried no pre-existing PowerShell formatting drift.
