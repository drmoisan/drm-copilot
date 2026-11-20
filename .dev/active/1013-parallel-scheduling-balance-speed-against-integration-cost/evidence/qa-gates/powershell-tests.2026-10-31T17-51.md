# PowerShell tests with coverage (P3-T4)

Timestamp: 2026-10-31T17-51
Command: Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1 (PowerShell 7 launched from a sh script under SCRATCH; module imported from scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary: pester-junit.xml: tests=22 failures=0 errors=0. Both `rejects repeated item keys` and `rejects a repeated item key with the distinct-keys message` are present and passed. artifacts/pester/powershell-coverage.xml was written. Line coverage for .claude/lib/blast-radius/BlastRadiusCombination.psm1 from that file: 72/72 = 100 percent (baseline 72/72; threshold 85). PSScriptAnalyzer on the edited test file with pssa.settings.psd1: 0 findings; Invoke-Formatter output identical to the file. PoshQC MCP format and analyze were also invoked (ok:true; no output carried) and git status showed no unexpected rewrite.
