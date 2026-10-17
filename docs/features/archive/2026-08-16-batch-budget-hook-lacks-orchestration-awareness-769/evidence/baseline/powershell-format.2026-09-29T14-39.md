# PowerShell Format Baseline (#769, P0-T13)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/hooks/*.ps*1 .codex/hooks/*.ps*1 tests/scripts/claude-hooks/*.ps1 tests/scripts/codex-hooks/*.ps1 scripts/powershell/PoshQC/settings/*.psd1
EXIT_CODE: 0
Output Summary:
Every FORMAT line reports Changed=False across the files matched in the five folders (including CHOOK, XHOOK, CTEST, XTEST, and both PoshQC settings files).
FORMAT-SUMMARY ChangedCount=0
