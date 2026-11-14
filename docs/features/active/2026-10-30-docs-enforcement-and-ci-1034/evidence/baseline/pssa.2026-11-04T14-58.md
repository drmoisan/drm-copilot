# PSScriptAnalyzer Baseline - Issue 1034

Timestamp: 2026-11-04T14-58
Command: sh SCRATCH/issue-1034-run.sh SCRATCH/issue-1034-pssa.ps1 -Path <five files below> (per file: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: 0 findings in total across the five files.

| File | Findings |
|---|---|
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 0 |
| .claude/lib/docs/DocsProfileCommands.psm1 | 0 |
| tests/scripts/claude-lib/docs/Docs.TestSupport.psm1 | 0 |
| tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 0 |
