# Remediation Baseline Reference (cycle 3 under OD-1, [P0-T2])

Timestamp: 2026-11-14T00-38
Command: git rev-parse c4a266194; git merge-base origin/main HEAD; sha256sum over the four commands-sibling copies and the six execution-environment SKILL.md copies; figures read from the two named evidence files
EXIT_CODE: 0
Output Summary: remediation start ref c4a26619489c1e8a8ab67d00b2187dbee6b07da7 (the branch head when cycle 3 execution began, before [P0-T1]); merge base of origin/main and HEAD eb73f1dff52e7175228a03740b53281c81e1c00c (origin/main equals it at this time). Phase 0 baseline repo-wide line coverage 95.80% (37558/39203). Head figures: repo-wide 95.86% (38934/40614); both commands copies 98.96% (95/96). Four sibling digests equal; six brief digests equal.

## Figures

| Source | Figure |
|---|---|
| `evidence/baseline/pester-gate.2026-11-10T04-19.md` (Phase 0 baseline) | repo-wide line coverage 95.80% (37558/39203) |
| `evidence/qa-gates/pester-gate.2026-11-13T19-43.md` (head) | repo-wide 95.86% (38934/40614); `.claude/hooks` commands copy 98.96% (95/96); `.codex/hooks` commands copy 98.96% (95/96); 22952 tests, 0 failures |

## SHA256

| File | SHA256 |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4 |
| `.claude/skills/execution-environment/SKILL.md` | 64fe1c6bca6b001d754f183d9bb9d1088644ecb2e1fc67d7158df9764c45d4d3 |
| `.agents/skills/execution-environment/SKILL.md` | 64fe1c6bca6b001d754f183d9bb9d1088644ecb2e1fc67d7158df9764c45d4d3 |
| `.github/skills/execution-environment/SKILL.md` | 64fe1c6bca6b001d754f183d9bb9d1088644ecb2e1fc67d7158df9764c45d4d3 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | 64fe1c6bca6b001d754f183d9bb9d1088644ecb2e1fc67d7158df9764c45d4d3 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | 64fe1c6bca6b001d754f183d9bb9d1088644ecb2e1fc67d7158df9764c45d4d3 |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | 64fe1c6bca6b001d754f183d9bb9d1088644ecb2e1fc67d7158df9764c45d4d3 |
