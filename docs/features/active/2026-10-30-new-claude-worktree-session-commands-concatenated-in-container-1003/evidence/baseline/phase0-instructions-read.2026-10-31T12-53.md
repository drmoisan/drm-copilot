# Phase 0 Instructions Read (Issue #1003)

Timestamp: 2026-10-31T12-53
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> typescript -> typescript-suppressions -> quality-tiers -> tonality -> execution-environment skill -> evidence-and-timestamp-conventions skill

Files read:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/typescript.md`
5. `.claude/rules/typescript-suppressions.md`
6. `.claude/rules/quality-tiers.md`
7. `.claude/rules/tonality.md`
8. `.claude/skills/execution-environment/SKILL.md`
9. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Notes:
- `quality-tiers.yml` exists at the repository root; `extensions/drm-copilot` is T3 per the plan assumptions. Coverage gates: lines 85, branches 75 per changed production file.
- TypeScript toolchain order: Prettier, ESLint, tsc, Jest (through `node run-jest.cjs` in `extensions/drm-copilot/`).
- SCRATCH is `<session scratchpad>/issue-1003/` and is recorded as the token `SCRATCH`.
