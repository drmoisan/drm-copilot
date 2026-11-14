# PowerShell format baseline over CHANGED-PS ([P0-T2])

Timestamp: 2026-11-07T22-43
Command: sh SCRATCH/issue-1038-static-changed.sh check issue-1038-static-p0.txt (PowerShell 7: Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over each file text, comparing the formatted text with the committed text; no file written)
EXIT_CODE: 0
Output Summary: 3 files checked; 0 files whose formatted text differs from the committed text.

Files:

- tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1
- tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1
- tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1

FORMAT-CHANGED-FILES: 0
