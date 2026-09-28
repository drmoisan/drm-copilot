# Final Mirror Hash Table (Issue #697, AC-6.1)

Timestamp: 2026-09-26T00-10
Command: Get-FileHash -Algorithm SHA256 for each source and mirror pair enumerated in [P15-T2]
EXIT_CODE: 0
Output Summary: every pair has equal hashes. [P14-T1] added no pair (no iteration of the MCP format call changed a file).
Count note: the task text says "the ten pairs listed above"; its enumeration yields nine distinct source-mirror pairs (the hook, `CodexDeployment.psm1` against two mirrors, `CodexTopology.psm1`, the three `.codex/scripts` files, the skill, and the runsettings file). All nine are listed below; no enumerated pair was omitted.

| # | Source | Mirror | Source SHA-256 | Mirror SHA-256 | Result |
| --- | --- | --- | --- | --- | --- |
| 1 | `.codex/hooks/enforce-epic-planning-only.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` | `B9FD4B9AF987DDC64F928F41A70F053647CA67F873FD8E7426E4DB305F430883` | `B9FD4B9AF987DDC64F928F41A70F053647CA67F873FD8E7426E4DB305F430883` | equal |
| 2 | `.claude/lib/codex-routing/CodexDeployment.psm1` | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` | equal |
| 3 | `.claude/lib/codex-routing/CodexDeployment.psm1` | `extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` | `6D9A830D65116C344FF349365ECE29DE217CF5C46E2324D6A33A09FE7EF96BF5` | equal |
| 4 | `.claude/lib/codex-routing/CodexTopology.psm1` | `extensions/drm-copilot/resources/lib/codex-routing/CodexTopology.psm1` | `F7458EE4C3F46DB9DFC2A4B38F333F1E61A6C5738C11B74D36AD587FBDC2AFFD` | `F7458EE4C3F46DB9DFC2A4B38F333F1E61A6C5738C11B74D36AD587FBDC2AFFD` | equal |
| 5 | `.codex/scripts/codex-routing-cli-common.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/codex-routing-cli-common.ps1` | `B9E2952A70F9E7B18DC424BB41CC84B16A0677E4732CE55110B12928842FD04D` | `B9E2952A70F9E7B18DC424BB41CC84B16A0677E4732CE55110B12928842FD04D` | equal |
| 6 | `.codex/scripts/Resolve-CodexTopology.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexTopology.ps1` | `71A29FE96D7F70F73B4632AC7A3FAB029D558EBCF2F75C8287A09C15B06AC578` | `71A29FE96D7F70F73B4632AC7A3FAB029D558EBCF2F75C8287A09C15B06AC578` | equal |
| 7 | `.codex/scripts/Resolve-CodexDeployment.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexDeployment.ps1` | `71083E936934283935CD727291C43D5AABA1C7A3AA3E791B4590925065DF6A6C` | `71083E936934283935CD727291C43D5AABA1C7A3AA3E791B4590925065DF6A6C` | equal |
| 8 | `.agents/skills/codex-model-routing/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/codex-model-routing/SKILL.md` | `FB77EEA11FEAC1FFF6B9FACECFDF6459E777F52626032900F64F2D984B6F6185` | `FB77EEA11FEAC1FFF6B9FACECFDF6459E777F52626032900F64F2D984B6F6185` | equal |
| 9 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `DA0BBDE1E7A1F2AE150B508E3AF3142C2604BD365DE065AA8E7D70EBB1A33072` | `DA0BBDE1E7A1F2AE150B508E3AF3142C2604BD365DE065AA8E7D70EBB1A33072` | equal |
