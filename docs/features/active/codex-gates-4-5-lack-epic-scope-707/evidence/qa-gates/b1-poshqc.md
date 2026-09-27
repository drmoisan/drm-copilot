# B1 Batch Toolchain: Format and Analyze ([P1-T11])

Timestamp: 2026-09-27T06-52
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p1-t11 (fresh PowerShell 7 process, working directory <WORKSPACE_ROOT>: SHA-256 of the seven batch files, then `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force`, `Invoke-PoshQCFormat -Root $root`, `Invoke-PoshQCAnalyze -Root $root`, then SHA-256 again)
EXIT_CODE: 0
Output Summary: First run was clean, so no fix loop was needed. Formatted count 0, Already formatted count 536. Analyzer: "PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>". All seven hashes unchanged; each mirror pair recorded in evidence/other/mirror-log.md after the latest byte copy is equal and still matches its source.

## Formatter

- `Formatted: ` count: 0
- `Already formatted: ` count: 536

## Analyzer outcome

```
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
```

## Hash Delta

| File | Before SHA-256 | After SHA-256 | Mark |
| --- | --- | --- | --- |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5 | 89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5 | unchanged |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7 | A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7 | unchanged |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | unchanged |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | E24B39A8C91A095035E96FDC66303D1562FF70D6BAD7857B2B6B4A83E47DECD7 | E24B39A8C91A095035E96FDC66303D1562FF70D6BAD7857B2B6B4A83E47DECD7 | unchanged |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5 | 89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5 | unchanged |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7 | A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7 | unchanged |
| extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | unchanged |

## Mirror pair parity after the latest byte copy

- Runsettings pair ([P1-T6]): equal (DFCCA8C1...).
- Resolution sibling pair ([P1-T8]): equal (89BB099C...).
- Epic-scope sibling pair ([P1-T8]): equal (A064ED68...).
