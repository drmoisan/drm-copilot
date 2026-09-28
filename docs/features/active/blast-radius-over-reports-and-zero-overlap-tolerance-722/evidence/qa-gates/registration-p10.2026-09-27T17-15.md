# Phase 10 Registration: Runsettings, Mirror, and Pack Manifest (P10-T9)

Timestamp: 2026-09-27T17-15
Command: sh SCRATCH/run-ps.sh SCRATCH/psd1-parse.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary: The self-hosted runsettings file lists .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 in the blast-radius coverage paths and parses (A11 printed PSD1-OK). A10 copied it to the bundled runsettings mirror (COPIED line printed), and A5 printed equal Hash values for the pair. The Claude pack manifest core.json lists the write-intent module next to the other blast-radius modules and parses as JSON (CORE-JSON-OK).

## Commands and outputs

| Command | EXIT_CODE | Printed |
| --- | --- | --- |
| sh SCRATCH/run-ps.sh SCRATCH/copy-file.ps1 -Source scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 0 | COPIED scripts/powershell/PoshQC/settings/pester.runsettings.psd1 |
| sh SCRATCH/run-ps.sh SCRATCH/psd1-parse.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 0 | PSD1-OK file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1 |
| sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 (the runsettings pair) | 0 | see below |
| poetry run python -c (json.load of extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json, then print CORE-JSON-OK) | 0 | CORE-JSON-OK |

## A5 output

```text
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=323C6BB5A1E577A0CEEDB8070DB831D8D4F3FE94AE0A403ECDCEDE235333D080
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=323C6BB5A1E577A0CEEDB8070DB831D8D4F3FE94AE0A403ECDCEDE235333D080
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
