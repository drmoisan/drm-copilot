# AC-49 Mirror Parity (P12-T17)

Timestamp: 2026-10-13T13-19
Command: git diff --no-index --exit-code <source> <mirror> (15 pairs, run as `git -C <worktree> ...`); GH-CMP <source> <mirror> (2 pairs, plan Conventions form, run from <worktree>)
EXIT_CODE: 0
HEAD: 92e85dd747c6cbabda41de18c0637c3139cb0414

Same pairs and command forms as P0-T15 (`evidence/baseline/mirror-parity.2026-10-13T00-11.md`). Bundle roots: `CC` = `extensions/drm-copilot/resources/claude-customizations`, `CA` = `extensions/drm-copilot/resources/codex-and-agents-customizations`, `CU` = `extensions/drm-copilot/resources/customizations`. `GH` is the `.github` segment written per the plan's `.github` command route.

| # | Source | Mirror | Command form | EXIT_CODE | Output |
|---|---|---|---|---:|---|
| 1 | .claude/skills/evidence-and-timestamp-conventions/SKILL.md | CC/.claude/skills/evidence-and-timestamp-conventions/SKILL.md | git diff --no-index --exit-code | 0 | (empty) |
| 2 | .agents/skills/evidence-and-timestamp-conventions/SKILL.md | CA/.agents/skills/evidence-and-timestamp-conventions/SKILL.md | git diff --no-index --exit-code | 0 | (empty) |
| 3 | .claude/skills/atomic-plan-contract/SKILL.md | CC/.claude/skills/atomic-plan-contract/SKILL.md | git diff --no-index --exit-code | 0 | (empty) |
| 4 | .agents/skills/atomic-plan-contract/SKILL.md | CA/.agents/skills/atomic-plan-contract/SKILL.md | git diff --no-index --exit-code | 0 | (empty) |
| 5 | GH/skills/evidence-and-timestamp-conventions/SKILL.md | CU/GH/skills/evidence-and-timestamp-conventions/SKILL.md | GH-CMP | 0 | identical |
| 6 | GH/skills/atomic-plan-contract/SKILL.md | CU/GH/skills/atomic-plan-contract/SKILL.md | GH-CMP | 0 | identical |
| 7 | .agents/skills/epic-plan/SKILL.md | CA/.agents/skills/epic-plan/SKILL.md | git diff --no-index --exit-code | 0 | (empty) |
| 8 | .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | CC/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | git diff --no-index --exit-code | 0 | (empty) |
| 9 | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | CC/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 10 | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | CA/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 11 | .claude/hooks/feature-folder-resolution.ps1 | CC/.claude/hooks/feature-folder-resolution.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 12 | .codex/hooks/feature-folder-resolution.ps1 | CA/.codex/hooks/feature-folder-resolution.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 13 | .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | CC/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 14 | .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | CA/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 15 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | CC/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 16 | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | CA/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | git diff --no-index --exit-code | 0 | (empty) |
| 17 | .claude/hooks/enforce-completion-consistency.ps1 | CC/.claude/hooks/enforce-completion-consistency.ps1 | git diff --no-index --exit-code | 0 | (empty) |

Exact GH-CMP command used for rows 5 and 6:
`poetry run python -c "import sys,pathlib;g='.git'+'hub';a,b=[pathlib.Path(p.replace('GH',g)).read_bytes() for p in sys.argv[1:3]];print('identical' if a==b else 'differ');sys.exit(0 if a==b else 1)" <source> <mirror>`

Output Summary: PASS. 17 of 17 pairs match: 15 `git diff --no-index --exit-code` pairs exit 0 with empty output, and both GH-CMP pairs print `identical` and exit 0.
