# Final QA: analyzer gate ([P7-T2])

Timestamp: 2026-11-04T02-19
Command: pwsh -NoProfile -File SCRATCH/issue-1033-pssa-files.ps1 -Root <worktree> -Folder .claude/lib/docs,tests/scripts/claude-lib/docs (a direct `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` call per `.ps1`, `.psm1` and `.psd1` file found recursively under the two folders, with up to two retries after re-importing PSScriptAnalyzer, because the recursive folder form of the call intermittently throws a null reference and hangs on this host; the same settings file and the same file set as the recursive form)
EXIT_CODE: 0
Output Summary: FILES analyzed=60; FINDINGS total=0 error=0 warning=0 information=0 parseerror=0. No file reported a retry on this pass. Zero findings: no fix, no mirror re-sync and no loop restart needed.
