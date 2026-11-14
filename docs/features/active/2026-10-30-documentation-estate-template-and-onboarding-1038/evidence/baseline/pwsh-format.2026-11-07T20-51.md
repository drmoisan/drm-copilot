# PowerShell format baseline (TDOCS)

Timestamp: 2026-11-07T20-51
Command: sh SCRATCH/issue-1038-static-baseline.sh (PowerShell 7: for every *.ps1 and *.psm1 under tests/scripts/claude-lib/docs, Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 in check form, comparing the formatted text and the file SHA-256 before and after; no file written)
EXIT_CODE: 0
Output Summary: 112 files checked; 0 files whose formatted text differs from the committed text (FORMAT-CHANGED-FILES: 0); every SHA-256 pair equal because check form writes nothing.
