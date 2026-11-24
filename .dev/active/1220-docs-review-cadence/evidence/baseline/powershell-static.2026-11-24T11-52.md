# PowerShell Static Baseline (P0-T2)

Timestamp: 2026-11-24T11-52
Command: sh SCRATCH/issue-1220-static.sh SCRATCH/issue-1220-p0-files.txt (pwsh 7: per file, Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text, check mode, no write; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: 5 files; format check 0 files would change; analyzer 0 findings.

| File | Format step (would change) | Analyzer findings |
|---|---|---|
| .claude/lib/docs/DocsPageMetadata.psm1 | False | 0 |
| .claude/lib/docs/DocsPageFrontMatter.psm1 | False | 0 |
| .claude/lib/docs/DocsValidation.psm1 | False | 0 |
| .claude/lib/docs/DocsValidateCommands.psm1 | False | 0 |
| .claude/lib/docs/DocsReferenceFrontMatter.psm1 | False | 0 |

Step commands and exit codes:
- Format check (Invoke-Formatter comparison): exit 0, 0 files differ.
- PSScriptAnalyzer: exit 0, 0 findings.
