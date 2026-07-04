# Phase 0 — Policy Reads (Issue #279)

Timestamp: 2026-07-03T14-45

Policy Order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/typescript-code-change.instructions.md`
6. `.github/instructions/typescript-unit-test.instructions.md`
7. `.claude/rules/general-code-change.md`
8. `.claude/rules/general-unit-test.md`
9. `.claude/rules/typescript.md`
10. `.claude/rules/typescript-suppressions.md`

Files read (verified, full content reviewed in this session):

- `CLAUDE.md` (repo root) — tone policy, policy-compliance reading order, four-layer architecture.
- `.github/copilot-instructions.md` — tone policy (strictly professional, no jokes/emojis/hype).
- `.github/instructions/general-code-change.instructions.md` — baseline design principles, bugfix workflow (failing-regression-test-first), mandatory toolchain loop (format -> lint -> type-check -> test), 500-line file limit, error handling/logging, naming, I/O boundaries.
- `.github/instructions/general-unit-test.instructions.md` — cross-language unit test policy: independence/isolation/fast/deterministic/readable, coverage floors (repo-wide >=80% line, new code >=90%), AAA structure, no external dependencies, no temp files.
- `.github/instructions/typescript-code-change.instructions.md` — TypeScript toolchain commands (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`), strong typing, ES modules only, suppression authorization requirement.
- `.github/instructions/typescript-unit-test.instructions.md` — Jest is the required TypeScript test framework; `.test.ts` naming; AAA; mocking/reset guidance.
- `.claude/rules/general-code-change.md` — mirrors general-code-change.instructions.md; adds module rigor tiers reference and uniform 500-line limit.
- `.claude/rules/general-unit-test.md` — mirrors general-unit-test.instructions.md; states the uniform repo-wide coverage floor actually enforced in `.claude/rules/quality-tiers.md` (line >=85%, branch >=75%, uniform across T1-T4), test file location (mirrored `tests/` tree; no colocation).
- `.claude/rules/typescript.md` — TypeScript toolchain summary; notes coverage thresholds follow the uniform tier rule (line >=85%, branch >=75%).
- `.claude/rules/typescript-suppressions.md` — pre-authorized suppression patterns (`eslint-disable-next-line` and `@ts-expect-error`, both requiring `-- <reason>`); prohibited patterns (`@ts-ignore`, `@ts-nocheck`, file-level disables).

Note on toolchain-command discrepancy: `.claude/rules/typescript.md` and `general-unit-test.instructions.md` reference Vitest/repo-wide 80% floors in places, but the plan's verified Toolchain note (checked against `extensions/drm-copilot/package.json` and `jest.config.cjs`) establishes that this package (`extensions/drm-copilot`) actually uses Jest via `node run-jest.cjs`, with no `test:coverage` script; coverage is obtained via `npm test -- --coverage`. This session follows the plan's verified commands, consistent with `.github/instructions/typescript-code-change.instructions.md` and `.github/instructions/typescript-unit-test.instructions.md`, both of which also specify Jest for this repo.

Acceptance check: artifact exists and lists every required file above. PASS.
