# Remediation Inputs: Integration-branch merge conflict record (2026-10-01T15-55)

- Feature folder: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509`
- Conflicting branches: `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (head `4a983ad6`) and `origin/epic/orchestrator-state-contract-correctness-integration` (tip `bb03e697`, containing sibling #523 via PR #808, merge `2bd929ba`, and current `main`)
- Procedure: `.claude/skills/epic-orchestrate/SKILL.md` "Merge-Conflict Handling (Fan-In)", applied at resume ahead of PR authoring (EA-3)
- Severity: Blocking (resolved in the merge commit; verification is owed by remediation cycle 1)
- Disposition: folded into remediation cycle 1 as a supplementary input, because cycle 1 was still at R1 (plan not yet preflight-cleared) when the merge ran.

## Conflict-Detection Output

Command: `git merge --no-edit origin/epic/orchestrator-state-contract-correctness-integration`

Conflicted file list (`git diff --name-only --diff-filter=U`):

- `extensions/drm-copilot/jest.config.cjs`

Auto-merged without conflict: `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, and their bundled copies under `extensions/drm-copilot/resources/`.

Marker excerpt (`extensions/drm-copilot/jest.config.cjs`, `coverageThreshold` map):

```text
<<<<<<< HEAD
    // Issue #509: the issue-adoption resolver and the routing validator that
    // consumes it. Per-file entries only; the map has no `global` key.
    "./src/lib/validate/orchestrator-state-issue-adoption.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/orchestrator-state-routing.ts": {
=======
    "./src/lib/validate/orchestrator-state-blocked-reason.ts": {
>>>>>>> origin/epic/orchestrator-state-contract-correctness-integration
      lines: 85,
      branches: 75,
    },
```

## Resolution Applied

Both children's additions are kept: the #523 entry `./src/lib/validate/orchestrator-state-blocked-reason.ts` followed by the #509 entries `./src/lib/validate/orchestrator-state-issue-adoption.ts` and `./src/lib/validate/orchestrator-state-routing.ts`, each with `lines: 85` and `branches: 75`. No function is edited by both children.

Bundled-copy byte identity after the merge (verified with `cmp`, all identical):

- `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`
- `.agents/skills/orchestrator-workflow/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`

## Verification Owed by Cycle 1

- The jest coverage-threshold map contains all three entries and the full TypeScript coverage run passes (`npx jest --coverage` from `extensions/drm-copilot`).
- The four documents above remain byte-identical to their bundled copies.
- The full Python suite and the docs-mirror and bundle-parity tests pass on the merged tree.
