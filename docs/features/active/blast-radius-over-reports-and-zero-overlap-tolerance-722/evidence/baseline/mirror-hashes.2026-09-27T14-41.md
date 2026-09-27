# Mirror-pair Hashes (P0-T14)

Timestamp: 2026-09-27T14-41
Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/lib/blast-radius/BlastRadius.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 .claude/lib/blast-radius/BlastRadiusValidation.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md .claude/agents/parallel-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
EXIT_CODE: 0
Output Summary: Exit 0; fourteen SHA256 lines. All seven primary/mirror pairs are byte-identical at baseline (hashes equal). Per the Preamble mirror rule, every mirror in this plan is produced by copying the edited primary with script A10.

## Pair verdicts

| Pair | Primary | Mirror | SHA256 | Equal |
| --- | --- | --- | --- | --- |
| 1 BlastRadius module | .claude/lib/blast-radius/BlastRadius.psm1 | extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1 | 89893D40F8F5C34889B19C051F8232289776C8D3B808039EF84E1615B27BB4B9 | yes |
| 2 BlastRadiusValidation module | .claude/lib/blast-radius/BlastRadiusValidation.psm1 | extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1 | B3DE478E0D997FE96D60805D123555D1DCF5419A4C43C3F45627A13B59CB763F | yes |
| 3 Pester runsettings | scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | DFCCA8C116853F49B42BBC387669AD385ABF8BE6F4D60F9546FDB8B6581D3A71 | yes |
| 4 parallel-orchestration rule | .claude/rules/parallel-orchestration.md | extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md | 8C31DA69A734805550B878CC83776F5FCFF8FD00CBEFD84B01B4C0BD7C962BB5 | yes |
| 5 parallel-plan skill | .claude/skills/parallel-plan/SKILL.md | extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md | CBD10C15B016AFEC4FA35B7C4438EA68676EC2D76B63955C008C9B1FA8951124 | yes |
| 6 parallel-add skill | .claude/skills/parallel-add/SKILL.md | extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md | 235DEB99EB76725CB377D63AAF0691917A28B1E9E8311AF3117A16004DBB4488 | yes |
| 7 parallel-planner agent | .claude/agents/parallel-planner.md | extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md | F09F0A3C11FB6D6DA2F097E87AE61EA5862C67870A16C05C802B6D59D09FEFEE | yes |
