# Final QA: PowerShell Static (P4-T4)

Timestamp: 2026-11-23T12-11
Command: sh SCRATCH/issue-1219-static.sh -FolderList ALL (PowerShell 7; imports branch-current scripts/powershell/PoshQC/PoshQC.psd1; step 1 Invoke-PoshQCFormat over every PowerShell file PoshQC discovers under the worktree root, in check mode with a non-writing -WriteFile; step 2 Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information on the same files); type check N/A (PowerShell)
EXIT_CODE: 0
Output Summary:
- Format (Invoke-Formatter through Invoke-PoshQCFormat): EXIT_CODE 0; 1869 files; 1869 `Already formatted:`; 0 lines beginning with `Formatted:` (clean format pass). Finding count: 0.
- Analyze (PSScriptAnalyzer): EXIT_CODE 0; 1869 files; 0 findings; 0 intermittent-engine retries in this run.
- Type check: N/A (PowerShell has no type checker; no TypeScript or Python production file changed).
- Run window: 2026-11-23T11-56 to 2026-11-23T12-07; no file was rewritten, so the loop needed no restart.
