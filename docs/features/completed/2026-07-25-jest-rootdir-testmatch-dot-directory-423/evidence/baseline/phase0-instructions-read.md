# Phase 0 — Policy Instructions Read

Timestamp: 2026-07-26T00-54

Task: [P0-T1]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Work Mode: full-bug (spec.md is the sole acceptance-criteria source; user-story.md intentionally absent)

## Policy Order

The repository policy-compliance order defined in `.claude/skills/policy-compliance-order/SKILL.md` was
followed:

1. `CLAUDE.md` (standing instructions, auto-loaded)
2. `.claude/rules/general-code-change.md` (cross-language code change policy)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy)
4. Language-specific rules for the files in scope (TypeScript / JavaScript config + test files):
   - `.claude/rules/typescript.md`
   - `.claude/rules/typescript-suppressions.md`

## Files Read

- `CLAUDE.md` — repository tone policy, policy-compliance reading order, four-layer runtime
  architecture, orchestration checkpoint path.
- `.claude/rules/general-code-change.md` — design principles, module rigor tiers, mandatory
  seven-stage toolchain loop (format → lint → type-check → architecture → unit tests → contract →
  integration), 500-line file size limit, error handling, naming, dependency policy, I/O boundaries.
- `.claude/rules/general-unit-test.md` — five core unit-test properties, coverage requirements
  (line >= 85%, branch >= 75% uniformly), coverage exclusion policy, scenario completeness,
  Arrange–Act–Assert structure, prohibition on temporary files in tests, test file location
  (`tests/` tree mirroring production source), determinism infrastructure.
- `.claude/rules/typescript.md` — TypeScript toolchain (Prettier, ESLint, TSC, test), coding
  standards, ESLint stack, testing standards, architecture boundaries, determinism.
- `.claude/rules/typescript-suppressions.md` — authorization requirement for suppressions,
  pre-authorized single-line patterns
  (`// eslint-disable-next-line <rule-name> -- <reason>`, `// @ts-expect-error -- <reason>`),
  explicitly prohibited file-level suppression patterns.

Additional auto-loaded rules present in session context and reviewed for applicability:
`.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/orchestrator-state.md`,
`.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md`. None of these constrain the
six in-scope files beyond the rules listed above.

## Known Documentation Discrepancy

`.claude/rules/typescript.md` (sections "Toolchain" item 4, "Testing Standards", "Runtime
Determinism") names **Vitest** as the TypeScript unit-test framework and references `vi.spyOn`,
`vi.mock`, and `vi.useFakeTimers()`.

Observed repository state: both packages in scope install and run **Jest 30.4.2**:

- Root package: `jest` ^30.x with `ts-jest`, entry point `node run-jest.cjs`, config `jest.config.cjs`.
- Extension package (`extensions/drm-copilot`): `jest` ^30.x with `ts-jest`, `npm run test` →
  `node run-jest.cjs`, config `extensions/drm-copilot/jest.config.cjs`.
- All 169 existing test files in scope use Jest with `@jest/globals` imports.
- Neither package installs Vitest; there is no `vitest` binary, config, or dependency entry.

Consequence for this feature: the two new regression test files
(`tests/unit/jest-config-resolution.test.ts` and
`extensions/drm-copilot/test/jest-config-resolution.test.ts`) are authored as **Jest** tests using
`@jest/globals` imports, matching the installed toolchain and the 169 existing test files. Writing
Vitest tests would be non-executable in either package.

This discrepancy is **recorded, not a blocker**. `.claude/rules/**` is on this feature's forbidden
file list (owned by parallel orchestrations), so the rule file is not modified here. Reconciling
`.claude/rules/typescript.md` with the actual Jest toolchain is recorded as follow-up item 2 in
`spec.md` → "Rollout & Follow-up" and is owned by a rules-owning change.

EXIT_CODE: 0
Output Summary: All five required policy files read in the mandated order. One documentation
discrepancy recorded (typescript.md names Vitest; both packages run Jest 30.4.2). No blocker
identified. Proceeding to baseline capture.
