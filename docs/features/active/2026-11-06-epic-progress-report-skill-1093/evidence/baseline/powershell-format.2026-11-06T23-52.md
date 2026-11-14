# Baseline Formatter State — Issue #1093

Timestamp: 2026-11-06T23-52
Command: sh SCRATCH/issue-1093-qc.sh Compare <four files> (PowerShell 7: each file's text, line endings normalized to LF as Invoke-PoshQCFormat does, compared with `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; no file written); then `git status --porcelain`
EXIT_CODE: 0
Output Summary: all four files match the formatter output; `git status --porcelain` printed nothing (the comparison wrote no file).

| File | Result |
|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | match |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | match |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | match |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | match |

`git status --porcelain` (run after the comparison, before this artifact was written): empty.
