# Phase 0 — Policy Instructions Read (#414)

Timestamp: 2026-07-25T17-00

Plan: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md`
Tasks: [P0-T1], [P0-T2], [P0-T3], [P0-T4], [P0-T5]
Work Mode: full-bug (AC source: `spec.md` only)
Branch: `bug/npm-audit-brace-expansion`
In-scope language: TypeScript (repository root and `extensions/drm-copilot` are TypeScript projects; the lockfile refresh moves TypeScript-toolchain dependencies jest, c8, minimatch, glob, mocha).

## Policy Order

Per `.claude/skills/policy-compliance-order/SKILL.md`:

1. `CLAUDE.md` — repository standing instructions (tone policy, policy-compliance reading order, architecture).
2. `.claude/rules/general-code-change.md` — cross-language code change policy.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy.
4. Language-specific rules for the in-scope language (TypeScript):
   - `.claude/rules/typescript.md`
   - `.claude/rules/typescript-suppressions.md`

## Files Read In This Session

| Order | Task | File | Read |
|---|---|---|---|
| 1 | [P0-T1] | `CLAUDE.md` | yes |
| 2 | [P0-T2] | `.claude/rules/general-code-change.md` | yes |
| 3 | [P0-T3] | `.claude/rules/general-unit-test.md` | yes |
| 4 | [P0-T4] | `.claude/rules/typescript.md` | yes |
| 4 | [P0-T4] | `.claude/rules/typescript-suppressions.md` | yes |

Additional standing-context rule files loaded automatically into this session and reviewed:
`.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`.

Feature requirement sources read: `spec.md` (sole AC source, 11 criteria), plan `plan.2026-07-25T15-42.md`.

## Constraints Confirmed From The Policy Reads

- Toolchain loop order: format -> lint -> type-check -> test; restart from step 1 on any failure or file change (`general-code-change.md`, `typescript.md`).
- Coverage thresholds are uniform: line >= 85%, branch >= 75% (`general-unit-test.md`, `quality-tiers.md`); no coverage regression on changed lines.
- Policy documents under `.claude/rules/` and `.github/instructions/` must not be modified.
- No new dependencies; this change uses the existing npm `overrides` mechanism only.
- Prohibited in this feature: `npm audit fix --force`, edits to `packages/mcp-server/**`, `.github/workflows/**`, branch-protection configuration, and the four orchestration files named in the plan's Plan Conventions.

Output Summary: All required policy files for the in-scope TypeScript change were read in the prescribed order prior to any manifest edit. No policy file was modified.
