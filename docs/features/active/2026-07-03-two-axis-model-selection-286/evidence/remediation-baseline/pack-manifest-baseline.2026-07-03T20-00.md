# Pack-Manifest Completeness Baseline (Pre-Fix) — Issue #286 (CI-2)

- Timestamp: 2026-07-03T20-00
- Command: `pwsh -NoProfile -Command "$agents = Get-ChildItem 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/*.md' | ForEach-Object Name; $listed = @(); Get-ChildItem 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json' | ForEach-Object { $listed += (Get-Content $_.FullName -Raw | ConvertFrom-Json).paths }; $missing = $agents | Where-Object { ('.claude/agents/' + $_) -notin $listed -and $_ -ne 'pr-author.md' }; 'MISSING: ' + (($missing | Sort-Object) -join ', ')"`
- EXIT_CODE: 0

## Output Summary

`MISSING: commit-message.md, human-exception-runbook.md`

Exactly two bundled agent files are absent from every `pack-manifests/*.json` (excluding the documented pre-existing exception `pr-author.md`). These correspond to `.claude/agents/commit-message.md` and `.claude/agents/human-exception-runbook.md`, the CI-2 Blocking finding. Expected outcome after the Phase 2 core.json fix: empty missing set.
