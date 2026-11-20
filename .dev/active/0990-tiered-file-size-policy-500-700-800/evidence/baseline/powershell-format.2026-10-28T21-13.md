# PowerShell Format Baseline (check-only)

Timestamp: 2026-10-28T21-13
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -ScanFolders .claude/hooks,.claude/lib,.codex/hooks,scripts/ci,tests/scripts -WriteFile { no-op } -Logger { capture } (sh launcher under SCRATCH, PowerShell 7.6)
EXIT_CODE: 0
Output Summary:
- Log lines beginning with `Formatted:` (pre-existing drift, not repaired): 0
- Log lines beginning with `Already formatted:`: 597
- `git status --porcelain` captured before and after the run: byte-identical (`cmp` exit 0); the no-op writer wrote nothing.
