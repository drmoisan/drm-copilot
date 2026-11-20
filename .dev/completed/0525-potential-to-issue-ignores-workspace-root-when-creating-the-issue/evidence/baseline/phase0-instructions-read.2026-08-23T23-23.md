# Phase 0 — Policy Read Evidence

Timestamp: 2026-08-25T09-17

Plan: `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/plan.2026-08-23T23-23.md`
Tasks covered: [P0-T1], [P0-T2], [P0-T3], [P0-T4]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`

## Policy Order

1. `CLAUDE.md` — repository standing instructions, read in full ([P0-T1])
2. `.claude/rules/general-code-change.md` — cross-language code change policy ([P0-T2])
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy ([P0-T2])
4. `.claude/rules/typescript.md` — TypeScript toolchain and coding standards ([P0-T3])
5. `.claude/rules/typescript-suppressions.md` — pre-authorized suppression patterns ([P0-T3])
6. `.claude/rules/quality-tiers.md` — module rigor tiers and uniform coverage thresholds ([P0-T3])

## Files Read (explicit list)

All six files below were read in full, in the order listed above, from the workspace root named above.

| # | Path | Task | Read in full |
| --- | --- | --- | --- |
| 1 | `CLAUDE.md` | [P0-T1] | yes |
| 2 | `.claude/rules/general-code-change.md` | [P0-T2] | yes |
| 3 | `.claude/rules/general-unit-test.md` | [P0-T2] | yes |
| 4 | `.claude/rules/typescript.md` | [P0-T3] | yes |
| 5 | `.claude/rules/typescript-suppressions.md` | [P0-T3] | yes |
| 6 | `.claude/rules/quality-tiers.md` | [P0-T3] | yes |

## Constraints Recorded from the Reads

Constraints below are recorded because they bind later phases of this plan. They are a summary of the
files read, not a substitute for them.

- **Toolchain order (`general-code-change.md`).** Formatting, linting, type checking,
  architecture-boundary tests, unit tests, contract/schema checks, integration tests. Restart from
  step 1 if any stage fails or auto-fixes files. `extensions/drm-copilot/package.json` configures
  runners for four of the seven stages only: `format`, `lint`, `typecheck`, `test`.
- **File size limit (`general-code-change.md`).** No production, test, or reusable script file may
  exceed 500 lines. This binds [P4-T3], where the extension-level test file stands near the limit.
- **Coverage thresholds (`general-unit-test.md`, `quality-tiers.md`).** Line coverage >= 85% and
  branch coverage >= 75%, uniform across tiers T1 through T4 for TypeScript. No regression on
  changed lines.
- **Coverage exclusion policy (`general-unit-test.md`).** No production file under `src/` may be
  excluded from coverage measurement. Interface/type-only files with no executable behavior may be
  omitted from measurement; this is a clarification, not a lowered threshold.
- **Test isolation (`general-unit-test.md`).** Unit tests must not depend on external processes.
  This binds Settled Design Decision 7 in the plan, which forbids a PATH probe in the default slug
  resolver.
- **Temporary files (`general-code-change.md`, `general-unit-test.md`).** Creation and use of
  temporary files in tests is prohibited.
- **Test file location (`general-unit-test.md`).** Test files live in a test tree mirroring the
  production source structure; colocation under `src/` is not permitted.
- **TypeScript standards (`typescript.md`).** ES modules only, strong typing on exported APIs,
  kebab-case filenames, Jest with `*.test.ts` naming, Arrange-Act-Assert structure.
- **Suppressions (`typescript-suppressions.md`).** Only `// eslint-disable-next-line <rule> -- <reason>`
  and `// @ts-expect-error -- <reason>` are pre-authorized. File-level disables, `@ts-ignore`, and
  `@ts-nocheck` require explicit user approval.

## Evidence Location

All Phase 0 artifacts are written under
`docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/`.
No artifact is written under `artifacts/`.
