# Phase 5 Mirror and Helpers Parity at Execution Time ([P5-T7], AC-19, AC-24)

Timestamp: 2026-09-27T07-22
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p5-collect (fresh PowerShell 7 process, section `T7 PARITY SHA256`: `Get-FileHash -Algorithm SHA256` and `git hash-object -- <path>` for each file)
EXIT_CODE: 0
Output Summary: The three .codex/hooks files and their bundle copies, the runsettings pair, and the four helpers copies each show equal SHA-256 values and equal git hash-object values.

## Pairs

| Source | Bundle copy | SHA-256 (both) | git hash-object (both) | SHA-256 | git |
| --- | --- | --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `150F3F8466B607AAC12D16F668152DF6E9C6B0BF00E43EF3D86EA2C2F4D7B0D1` | `b480aec30b264877263baece369ac85f3649b67e` | equal | equal |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `A064ED683C3798FB6D02792FEEED5FE72CBA46DE81F4539FE4CCD12883BBD9F7` | `8ce8a17b9d1504bbc4304a8e0da538f9b9f2fae1` | equal | equal |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | `89BB099CC73E800603C34DADE4F80E73D1D9CCD4561E8454551F05EAB174B6B5` | `f2c39644d242b7208edf346e05fbd40768e17f25` | equal | equal |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71` | `f4a295e6e2eda3addd48112ba9e4805833d37ca3` | equal | equal |

## Helpers four-copy set

| Copy | SHA-256 | git hash-object |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65` | `4df8e0748274d1ab57a71debf52e11933fdbac0e` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65` | `4df8e0748274d1ab57a71debf52e11933fdbac0e` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65` | `4df8e0748274d1ab57a71debf52e11933fdbac0e` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65` | `4df8e0748274d1ab57a71debf52e11933fdbac0e` |

HELPERS_SHA: equal
HELPERS_GIT: equal
