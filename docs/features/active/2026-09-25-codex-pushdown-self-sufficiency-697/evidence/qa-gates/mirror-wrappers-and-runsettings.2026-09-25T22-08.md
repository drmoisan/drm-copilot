# Mirror: Routing Wrappers and Pester Runsettings (Issue #697, rule 6)

Timestamp: 2026-09-25T22-08
Command: Copy-Item -LiteralPath <source> -Destination <mirror> -Force for the three .codex/scripts files and pester.runsettings.psd1 (one PowerShell process); Get-FileHash -Algorithm SHA256
EXIT_CODE: 0
Output Summary: every mirror hash equals its source hash (4 pairs, 8 values).

| Path | SHA-256 |
| --- | --- |
| `.codex/scripts/codex-routing-cli-common.ps1` | `B9B0EBA80A2389EA9A141FB4DE89F9C923A4239208403C9FCA507C181F6712A0` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-routing-cli-common.ps1` | `B9B0EBA80A2389EA9A141FB4DE89F9C923A4239208403C9FCA507C181F6712A0` |
| `.codex/scripts/Resolve-CodexTopology.ps1` | `71A29FE96D7F70F73B4632AC7A3FAB029D558EBCF2F75C8287A09C15B06AC578` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexTopology.ps1` | `71A29FE96D7F70F73B4632AC7A3FAB029D558EBCF2F75C8287A09C15B06AC578` |
| `.codex/scripts/Resolve-CodexDeployment.ps1` | `71083E936934283935CD727291C43D5AABA1C7A3AA3E791B4590925065DF6A6C` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexDeployment.ps1` | `71083E936934283935CD727291C43D5AABA1C7A3AA3E791B4590925065DF6A6C` |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `DA0BBDE1E7A1F2AE150B508E3AF3142C2604BD365DE065AA8E7D70EBB1A33072` |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `DA0BBDE1E7A1F2AE150B508E3AF3142C2604BD365DE065AA8E7D70EBB1A33072` |
