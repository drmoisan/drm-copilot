# Phase 5 Registration ([P5-T6], AC-20, AC-22 registration part)

Timestamp: 2026-09-27T07-22
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p5-collect (fresh PowerShell 7 process, section `T6 REGISTRATION`: `Get-Content -Raw ... | ConvertFrom-Json` of extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json; `Import-PowerShellDataFile` of both pester.runsettings.psd1 copies; exact-match occurrence counts)
EXIT_CODE: 0
Output Summary: Six counts recorded, each exactly 1: both new .codex/hooks paths occur once in core.json `paths` and once in `CodeCoverage.Path` of each runsettings copy.

| Source | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` |
| --- | --- | --- |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` `paths` | 1 | 1 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` | 1 | 1 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` | 1 | 1 |
