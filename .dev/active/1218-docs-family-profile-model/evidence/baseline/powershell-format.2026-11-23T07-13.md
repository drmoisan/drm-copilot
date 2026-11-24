# PowerShell Format Baseline (Issue #1218, P0-T1)

Timestamp: 2026-11-23T07-13
Command: sh SCRATCH/issue-1218-qc.sh format-check .claude/lib/docs/DocsProfile.psm1 tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 (check mode: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared against the LF-normalized file text; no file written)
EXIT_CODE: 0
Output Summary:
- ALREADY-FORMATTED: .claude/lib/docs/DocsProfile.psm1
- ALREADY-FORMATTED: tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
- ALREADY-FORMATTED: tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
- Files needing formatting: none (TOTAL: 0).
- `git status --porcelain` after the run: empty (no tracked source change).
