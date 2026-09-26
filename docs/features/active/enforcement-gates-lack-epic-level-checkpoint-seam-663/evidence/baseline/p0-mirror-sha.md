# Mirror Baseline ([P0-T18])

Timestamp: 2026-09-25T19-08
Command: sh <SCRATCHPAD>/i663/run.sh p0-mirror  (fresh process; Get-FileHash -Algorithm SHA256 over repository-relative paths)
EXIT_CODE: 0
Output Summary: Nine source/mirror pairs, one four-copy helpers set, and one runsettings pair recorded; marks listed below.

## Source/Mirror Pairs

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Mark |
| --- | --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | aad0baaf088baa3227e42d6e0b4171352c4f51ba611dbf7bd145024c6f958989 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | aad0baaf088baa3227e42d6e0b4171352c4f51ba611dbf7bd145024c6f958989 | equal |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 218cbfadd55cc51547488332c33213339af42e56b73408005f97101a06d9c176 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 218cbfadd55cc51547488332c33213339af42e56b73408005f97101a06d9c176 | equal |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | c9c4787261cb94420f9dc89db7f64bbaeee4f758411030595a8599dc8c4870f5 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1 | c9c4787261cb94420f9dc89db7f64bbaeee4f758411030595a8599dc8c4870f5 | equal |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 2d8b610d4d2fe49b895c454f19148d7f5076377bd4638d30770a8bee36d37bc1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 2d8b610d4d2fe49b895c454f19148d7f5076377bd4638d30770a8bee36d37bc1 | equal |
| .claude/hooks/enforce-model-routing-receipt.ps1 | e31485c5d63a6483a7576a24e0bade590240cfdaa144e130c8f5dba74bce4922 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1 | e31485c5d63a6483a7576a24e0bade590240cfdaa144e130c8f5dba74bce4922 | equal |
| .claude/skills/epic-plan/SKILL.md | 39ecbb5ae26d49a480bc75a2a845c456b33d20dc66359a6aad9399e89068612f | extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md | 39ecbb5ae26d49a480bc75a2a845c456b33d20dc66359a6aad9399e89068612f | equal |
| .claude/skills/epic-orchestrate/SKILL.md | 75fb1667174481091a2437ab67160da9ec1d20232ae1ea77882c450be1d6e2b5 | extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md | 75fb1667174481091a2437ab67160da9ec1d20232ae1ea77882c450be1d6e2b5 | equal |
| .claude/agents/epic-planner.md | 7a0e56dfd89bd2a67d039ed352980f0e39027cb27db27fb5a49e844d762cda09 | extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md | 7a0e56dfd89bd2a67d039ed352980f0e39027cb27db27fb5a49e844d762cda09 | equal |
| .claude/agents/epic-orchestrator.md | 5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec | extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md | 5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec | equal |

## Helpers Four-Copy Set

- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: aad0baaf088baa3227e42d6e0b4171352c4f51ba611dbf7bd145024c6f958989
- .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: aad0baaf088baa3227e42d6e0b4171352c4f51ba611dbf7bd145024c6f958989
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: aad0baaf088baa3227e42d6e0b4171352c4f51ba611dbf7bd145024c6f958989
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: aad0baaf088baa3227e42d6e0b4171352c4f51ba611dbf7bd145024c6f958989
- Set mark: equal

## Runsettings Pair

- scripts/powershell/PoshQC/settings/pester.runsettings.psd1: 34c0104700bfa36c0abf1f64d865d9c035f677dfc76f2a373f32e16484a391dc
- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1: 34c0104700bfa36c0abf1f64d865d9c035f677dfc76f2a373f32e16484a391dc
- Pair mark: equal
