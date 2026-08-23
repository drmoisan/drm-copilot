# QA Gate — Final PowerShell Formatting — [P8-T6]

Timestamp: 2026-08-23T03-52

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T6]

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root,
bracketed by two captures of `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`.

EXIT_CODE: 0

Tool return, verbatim:

```json
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-22T22-50","summary":"Ran bundled PoshQC format against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-22T22-50'."}
```

The tool reports `ok: true`.

## Before snapshot, verbatim

```text
M  .claude/lib/blast-radius/BlastRadiusExtraction.psm1
A  .claude/lib/blast-radius/BlastRadiusTokenShape.psm1
M  extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
A  extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
M  extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
M  scripts/powershell/PoshQC/settings/pester.runsettings.psd1
M  tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
M  tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
A  tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
```

## After snapshot, verbatim

```text
M  .claude/lib/blast-radius/BlastRadiusExtraction.psm1
A  .claude/lib/blast-radius/BlastRadiusTokenShape.psm1
M  extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
A  extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
M  extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
M  scripts/powershell/PoshQC/settings/pester.runsettings.psd1
M  tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
M  tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
A  tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
```

## The two snapshots are byte-identical

Nine entries in each, in the same order, with the same status codes. **PASS.**

The entries are non-empty in both snapshots because [P8-T5] ran `git add -A` immediately before this
task, so this item's nine PowerShell-family changes are staged and appear with index status codes
(`M ` and `A `). That is pre-existing state relative to *this command*, and because it appears
identically in both snapshots it cancels, which is exactly what the paired form is for.

## Why the pair replaces a bare zero-files-changed reading

This is a write-mode formatter. Its return value carries only an ok flag, a tool name, a workspace
root, and a one-sentence summary; it names no file it rewrote and reports no count. Its exit status
is 0 whether or not it rewrote a file, so the exit code alone cannot observe a reformat. A single
post-hoc snapshot compares the worktree against the index and therefore cannot attribute a
modification to the command that just ran.

Two snapshots taken around the single invocation make the observation run-scoped: a rewrite from this
run would appear only in the after snapshot — as a worktree-modified flag alongside the staged one,
changing `M ` to `MM` or `A ` to `AM` — while state already present appears in both and cancels. No
entry changed, so the formatter rewrote no PowerShell file.

The pathspec is extension-based (`*.ps1`, `*.psm1`, `*.psd1`) so it covers every file the formatter
can write without depending on the formatter's own scan configuration.

## Restart-clause status

The snapshots are identical, so the formatting stage changed no PowerShell file and the Phase 8
restart clause is not triggered by this task.

## Output Summary

The tool reports ok. The before and after snapshots are byte-identical across all nine entries, so
the PowerShell formatting stage rewrote nothing. The paired observation is what establishes this,
since the tool's own return value cannot.
