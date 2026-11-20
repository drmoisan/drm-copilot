# Remediation Baseline Reference (cycle 2, [P0-T2])

Timestamp: 2026-11-13T18-34
Command: git -C <worktree> rev-parse HEAD; git -C <worktree> fetch origin main; git -C <worktree> merge-base origin/main HEAD; sha256sum of the four commands sibling copies and the six execution-environment SKILL.md copies
EXIT_CODE: 0
Output Summary: start ref and merge base recorded; four equal sibling digests; six equal brief digests; Phase 0 baseline and head coverage figures copied from the named artifacts.

## Remediation start ref

- Remediation start ref (`git rev-parse HEAD`, after the [P0-T1] evidence commit, before any source or test edit): `66ebab395d453502af66b8f64ddcb46c0ea81572`
- Merge base of `origin/main` and `HEAD`: `18520b3fce8b6273ac63a16fef03816f7119dcad`

## Phase 0 baseline (from `evidence/baseline/pester-gate.2026-11-10T04-19.md`)

- Merged JUnit: total 21311, passed 21301, failed 0, errors 0, skipped 10.
- Repo-wide line coverage: 95.80% (37558/39203 lines).

## Head figures (from `evidence/qa-gates/coverage-comparison.2026-11-13T17-27.md`)

- `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`: 98.68% (75/76).
- `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`: 98.68% (75/76).

## SHA256 — commands sibling copies (4 equal)

| Copy | SHA256 |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | `74265e76cc62977773d7d3ccdbfa7c4c514662395572712a6e6679b93250cbf0` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | `74265e76cc62977773d7d3ccdbfa7c4c514662395572712a6e6679b93250cbf0` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | `74265e76cc62977773d7d3ccdbfa7c4c514662395572712a6e6679b93250cbf0` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | `74265e76cc62977773d7d3ccdbfa7c4c514662395572712a6e6679b93250cbf0` |

## SHA256 — execution-environment SKILL.md copies (6 equal)

| Copy | SHA256 |
|---|---|
| `.claude/skills/execution-environment/SKILL.md` | `67cb26dd7a92b9ad85215cc2150d40c0ba1915ac371e51b52cc656ad428b53b7` |
| `.agents/skills/execution-environment/SKILL.md` | `67cb26dd7a92b9ad85215cc2150d40c0ba1915ac371e51b52cc656ad428b53b7` |
| `.github/skills/execution-environment/SKILL.md` | `67cb26dd7a92b9ad85215cc2150d40c0ba1915ac371e51b52cc656ad428b53b7` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | `67cb26dd7a92b9ad85215cc2150d40c0ba1915ac371e51b52cc656ad428b53b7` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | `67cb26dd7a92b9ad85215cc2150d40c0ba1915ac371e51b52cc656ad428b53b7` |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | `67cb26dd7a92b9ad85215cc2150d40c0ba1915ac371e51b52cc656ad428b53b7` |
