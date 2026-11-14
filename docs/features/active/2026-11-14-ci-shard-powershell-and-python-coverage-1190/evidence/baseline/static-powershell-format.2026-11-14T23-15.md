# Phase 0 baseline: PowerShell format check (P0-T1)

Timestamp: 2026-11-14T23-15
Command: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file over scripts/ci and tests/scripts/ci, comparing to the file text (check mode; no file written), run from an sh script under SCRATCH
EXIT_CODE: 0
Output Summary: files=15 would-change=0. No file differs from its formatted text.
