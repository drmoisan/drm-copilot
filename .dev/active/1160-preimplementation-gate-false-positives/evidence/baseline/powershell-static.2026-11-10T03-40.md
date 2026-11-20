# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-10T03-38
Command: sh SCRATCH/issue-1160-p0-static.sh (PowerShell 7: for each file, Invoke-Formatter -ScriptDefinition <file content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the file content, no write; then Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary:
- Files: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
- Format (non-writing): `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` formatter output equals file content (True); `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` formatter output equals file content (True).
- Analyzer: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` 0 findings; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` 0 findings.
- Totals: FORMAT_DIFF_FILES=0 FORMAT_WRITTEN=0 ANALYZER_FINDINGS=0.
- Tracked-file check: `git status --porcelain` after the task lists only this new evidence file (untracked); no tracked file changed.
