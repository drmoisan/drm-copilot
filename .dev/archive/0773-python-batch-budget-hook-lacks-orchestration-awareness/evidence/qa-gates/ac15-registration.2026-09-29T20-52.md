# AC-15 Registration Check (P10-T7)

Timestamp: 2026-09-29T20-52
Command: git ls-files -- .claude/hooks/enforce-powershell-batch-budget-route.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1; git grep -c -F -e 'enforce-powershell-batch-budget-route' -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1; git grep -c -F -e '.claude/hooks/enforce-batch-budget-route.ps1' -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json; git grep -c -F -e '.codex/hooks/enforce-batch-budget-route.ps1' -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json; git grep -c -F -e 'enforce-batch-budget-route.ps1' -- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary:
- git ls-files: no output (old helper and its bundle copy untracked).
- Old-helper name search: exit 1, no output.
- Claude core manifest: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:1
- Codex core manifest: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json:1
- New helper name: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:1, scripts/powershell/PoshQC/settings/pester.runsettings.psd1:2, extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1:2
