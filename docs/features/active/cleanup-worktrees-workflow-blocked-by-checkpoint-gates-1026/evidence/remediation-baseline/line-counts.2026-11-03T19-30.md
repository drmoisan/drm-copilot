# Remediation Baseline — Bases, Line Counts, Helpers Hash

Timestamp: 2026-11-03T19-30
Command: git merge-base origin/main HEAD; git rev-parse HEAD; wc -l <files>; sha256sum .claude/hooks/enforce-pr-author-skill-helpers.ps1
EXIT_CODE: 0

- MERGE_BASE: 01706c697f3ad4a53b4a771d99d851afc7417ea9
- CYCLE_BASE: 904a862ab83a4cb9f862426fbf6e2b1d60ffb906

| File | Physical lines |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 472 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 493 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 421 |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 198 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 499 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | 200 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` | 441 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` | 357 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` | 271 |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | 274 |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` | 110 |

- SHA256 `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: 7b751508417f484bf7dbf25ca8fcaccc4463399ce93fb6c0b44e8efa86f93a40

Output Summary: Codex gate 493 lines (cap 500, PASS); helpers 499 lines (cap 500, PASS). Counts are physical lines from wc -l, each file ending in a line terminator.
