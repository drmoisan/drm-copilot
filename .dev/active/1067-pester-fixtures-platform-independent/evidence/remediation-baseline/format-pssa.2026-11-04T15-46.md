# Baseline — format check and PSSA over the five change-set files (P0-T9)

Timestamp: 2026-11-04T15-46
Command: sh SCRATCH/issue-1067-fmt-pssa-files.sh base5 <five change-set files> (SCRATCH/issue-1067-format-check.ps1 and SCRATCH/issue-1067-pssa.ps1, each in a fresh pwsh -NoProfile process, read-only; Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0

Files:

- tests/scripts/dev-tools/link-feature-docs.Tests.ps1
- tests/scripts/dev-tools/link-parent-child.Tests.ps1
- tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
- tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
- tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1

```
FILES 5
FORMAT-DIFF-COUNT=0
FILES 5
PSSA-FINDINGS=0
```

Output Summary: FORMAT-DIFF-COUNT=0 and PSSA-FINDINGS=0 before any edit; no drift path and no finding is listed, so any later drift or finding is attributable to this cycle's edits.
