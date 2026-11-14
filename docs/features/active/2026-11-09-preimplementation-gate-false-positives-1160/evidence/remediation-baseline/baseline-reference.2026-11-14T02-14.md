# Remediation Baseline Reference (cycle 4, [P0-T2])

Timestamp: 2026-11-14T02-14
Command: git rev-parse HEAD; git fetch origin main; git rev-parse origin/main; git merge-base origin/main HEAD; sha256sum over the four commands-sibling copies and the six execution-environment SKILL.md copies; figures read from the two named evidence files
EXIT_CODE: 0
Output Summary: remediation start ref eb8781fd6fca43fe74b1b69392d27c7fd8a9e8f8 (branch head at the resume of cycle 4 execution, the coordinator's plain merge of origin/main). Merge base of origin/main and HEAD f9e817b2ace9875b24f3df8ad27b97a4065a435e (origin/main equals it at this time). Phase 0 baseline repo-wide line coverage 95.80% (37558/39203). Cycle 3 head figures: repo-wide 95.88% (39146/40828); both measured commands copies 99.01% (201/203). Four sibling digests equal; six brief digests equal.

## Note on the [P0-T1] static baseline

The [P0-T1] static baseline (`powershell-static.2026-11-14T02-09.md`) was captured on the pre-merge head (the commit of the [P0-T1] record, before the merge of origin/main). The merge brought in PR #1176 (issue #1161), which changed both `pack-manifests/core.json` files and two AC-17 suites on main's side and none of the six files that baseline measured, so the baseline stands and is not re-captured.

## Figures

| Source | Figure |
|---|---|
| `evidence/baseline/pester-gate.2026-11-10T04-19.md` (Phase 0 baseline) | repo-wide line coverage 95.80% (37558/39203) |
| `evidence/qa-gates/coverage-comparison.2026-11-14T01-33.md` (cycle 3 head) | repo-wide 95.88% (39146/40828); `.claude/hooks` commands copy 99.01% (201/203); `.codex/hooks` commands copy 99.01% (201/203) |

## SHA256

| File | SHA256 |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | c39100dc8993f1042a3ea621d4de6bc832feeae27193e0427fb65e9501c5414c |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | c39100dc8993f1042a3ea621d4de6bc832feeae27193e0427fb65e9501c5414c |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | c39100dc8993f1042a3ea621d4de6bc832feeae27193e0427fb65e9501c5414c |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | c39100dc8993f1042a3ea621d4de6bc832feeae27193e0427fb65e9501c5414c |
| `.claude/skills/execution-environment/SKILL.md` | 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490 |
| `.agents/skills/execution-environment/SKILL.md` | 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490 |
| `.github/skills/execution-environment/SKILL.md` | 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490 |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | 4dd9db4baf9abbf7a3f7e15503d7997059c92e068b607fb51ba3535e3957b490 |
