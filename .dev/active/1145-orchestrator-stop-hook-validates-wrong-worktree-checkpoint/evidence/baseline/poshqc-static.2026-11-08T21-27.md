# PowerShell Static Baseline (issue #1145, [P0-T1])

Timestamp: 2026-11-08T21-26
Command: sh SCRATCH/issue-1145-static.sh (PowerShell 7 launcher: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -ScanFolders .claude/hooks,tests/scripts/claude-hooks -WriteFile <recording seam> -Logger <recording seam>; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file under the same folders, PSScriptAnalyzer 1.25.0)
EXIT_CODE: 0
Output Summary:
- Scope: `.claude/hooks` and `tests/scripts/claude-hooks` (331 PowerShell files).
- Step 1, format (check-only; the recording `-WriteFile` seam rewrites no file): exit 0; 331 files checked; 0 files would be rewritten (finding count 0).
- Step 2, analyzer: exit 0; 331 files analyzed; 0 analyzer errors; 0 findings (finding count 0).
- Tree state after the run: `git status --porcelain` empty.
- Head: branch `bug/orchestrator-stop-hook-target-worktree` before any implementation task.
