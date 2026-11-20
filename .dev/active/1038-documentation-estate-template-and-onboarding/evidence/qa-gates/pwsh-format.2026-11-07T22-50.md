# PowerShell format gate over CHANGED-PS ([P4-T1])

Timestamp: 2026-11-07T22-50
Command: sh SCRATCH/issue-1038-static-changed.sh write issue-1038-static-final.txt (PowerShell 7: Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file, writing any change, with SHA-256 before and after)
EXIT_CODE: 0
Output Summary: 3 files; no formatted text differed from the file text, no file written; every before and after hash pair is equal.

CHANGED-FILES: 0

| File | SHA-256 before | SHA-256 after |
|---|---|---|
| tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1 | 8DE6DA47D8EC5F07C265DBFDFB68394B9AB1EB492FF48A382243679F9BDD5CDE | 8DE6DA47D8EC5F07C265DBFDFB68394B9AB1EB492FF48A382243679F9BDD5CDE |
| tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1 | 2E9C3FA8D6F5516FCE5B5128EA47D1E412A3950B1554CB43CBF6E9E59C896F13 | 2E9C3FA8D6F5516FCE5B5128EA47D1E412A3950B1554CB43CBF6E9E59C896F13 |
| tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1 | E6206A13509028348882A41856BF2EA0A74070C40F5578FB2C5F1BC24375EBA2 | E6206A13509028348882A41856BF2EA0A74070C40F5578FB2C5F1BC24375EBA2 |
