# QA gate: PSScriptAnalyzer (issue 1105, remediation cycle 1, pass 3)

Timestamp: 2026-11-07T16-52
Task: [P3-T1] (loop restart after the [P3-T4] coverage fix)
Command: sh SCRATCH/issue-1105-static.sh c1pass3 (pwsh -NoProfile -File SCRATCH/issue-1105-static.ps1: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` for every `*.ps1` and `*.psm1` under `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/codex-hooks`, plus an `Invoke-Formatter` comparison that writes nothing)
EXIT_CODE: 0
Output Summary:
- Files scanned: 392
- Findings: 0 (Error: 0, Warning: 0, Information: 0)
- Files with findings: none. This includes every file this cycle edits.
- Formatter comparison: 0 files would change.
- Baseline comparison: `poshqc-analyze.2026-11-07T14-34.md` recorded 0 findings, so there is no new finding.
