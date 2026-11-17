# PowerShell Static Baseline (P0-T2)

Timestamp: 2026-11-15T23-22
Command: sh SCRATCH/issue-1195-static.sh scoped (runs pwsh -NoProfile -File SCRATCH/issue-1195-static.ps1 -Mode scoped: imports scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat with a no-op -WriteFile seam, a collecting -Logger, and -GetFileList returning the 12 scoped files; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information per file; git status --porcelain captured before and after)
EXIT_CODE: 0
Output Summary:
- Scope (12 files): the four classify copies (.claude/hooks, .codex/hooks, both bundle hooks folders), the four gate copies, tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1, both classify Tests.ps1 files, tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1.
- Format step: exit 0; 12 files checked; "Formatted:" log lines (drift count) = 0; files the formatter would change: none.
- Analyzer step: exit 0; findings = 0.
- git status --porcelain: identical before and after.
