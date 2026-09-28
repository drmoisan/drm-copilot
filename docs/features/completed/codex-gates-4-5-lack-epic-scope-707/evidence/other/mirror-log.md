# Mirror Log (plan rule 6)

Every mirror is written with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force` inside a scratchpad script launched by route `sh` with working directory `<WORKSPACE_ROOT>`. Hashes are SHA-256 computed by `Get-FileHash` immediately after the copy.

## B1 runsettings ([P1-T6])

Timestamp: 2026-09-27T06-50
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p1-mirror-runsettings
EXIT_CODE: 0
Output Summary: One byte copy; the SHA-256 pair is equal.

Copy commands:

```
Copy-Item -LiteralPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 -Force
```

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Mark |
| --- | --- | --- | --- | --- |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | equal |

Note: a first launch of the copy script at 2026-09-27T06-50 failed before copying (`Cannot find path 's'`) because a single-pair array literal was flattened; the script was corrected with the unary comma operator and re-run. No file was written by the failed launch.

## B1 siblings ([P1-T8])

Timestamp: 2026-09-27T06-51
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p1-mirror-siblings
EXIT_CODE: 0
Output Summary: Two byte copies; both SHA-256 pairs are equal.

Copy commands:

```
Copy-Item -LiteralPath .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 -Force
Copy-Item -LiteralPath .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 -Force
```

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Mark |
| --- | --- | --- | --- | --- |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5 | equal |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7 | equal |

## B2 pre-insertion ([P2-T4])

Timestamp: 2026-09-27T07-00
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p2-mirror-gate
EXIT_CODE: 0
Output Summary: One byte copy of the gate after edits (a), (b), and (c) and before edit (d); the SHA-256 pair is equal.

Copy commands:

```
Copy-Item -LiteralPath .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 -Force
```

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Mark |
| --- | --- | --- | --- | --- |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | F156023D6CCFC8D6EE3DD2CCB109A331F1B0119B217F3D1339AE5809E0745AC9 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | F156023D6CCFC8D6EE3DD2CCB109A331F1B0119B217F3D1339AE5809E0745AC9 | equal |

## B2 final ([P2-T7])

Timestamp: 2026-09-27T07-01
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p2-mirror-gate
EXIT_CODE: 0
Output Summary: One byte copy of the gate after edit (d); the SHA-256 pair is equal.

Copy commands:

```
Copy-Item -LiteralPath .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 -Destination extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 -Force
```

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Mark |
| --- | --- | --- | --- | --- |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1 | equal |
