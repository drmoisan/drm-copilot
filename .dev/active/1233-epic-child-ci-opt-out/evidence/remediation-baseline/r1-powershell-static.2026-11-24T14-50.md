# R1 remediation baseline: PowerShell static (P0-T1)

Timestamp: 2026-11-24T14-50
Command: sh SCRATCH/issue-1233-r1-static.sh r1-p0-static SCRATCH/issue-1233-r1-files.txt (runs pwsh -NoProfile -File SCRATCH/issue-1233-ps-static-runtime.ps1: Invoke-PoshQCFormat -WriteFile { no-op } ; Invoke-PoshQCAnalyze ; Invoke-PoshQCLeakScan, then SCRATCH/issue-1233-ps-files.ps1 check: Invoke-Formatter comparison and Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per listed file; git status --porcelain before and after)
EXIT_CODE: 0
Output Summary:
- Files (10): .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1, .claude/hooks/enforce-epic-merge-gate-child-ci.ps1, .codex/hooks/enforce-epic-merge-gate-child-ci.ps1, .codex/hooks/enforce-epic-merge-gate.ps1, the four bundle copies under extensions/drm-copilot/resources/, tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1, tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1.
- Format: Invoke-PoshQCFormat with the non-writing -WriteFile seam; exit 0; drift count 0 (0 "Formatted:" lines repo-wide, 1894 "Already formatted:"); per-file Invoke-Formatter check: 10 of 10 "Already formatted", drift 0.
- Lint: Invoke-PoshQCAnalyze exit 0 ("PSScriptAnalyzer passed: no findings"); per-file Invoke-ScriptAnalyzer: 0 findings across the 10 files.
- Leak scan: Invoke-PoshQCLeakScan exit 0 ("Leak scan: 916 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.").
- git status --porcelain identical before and after; no file rewritten.
