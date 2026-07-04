# Phase 0 — Policy Instructions Read (F11 ts-command-runtime-cleanup)

Timestamp: 2026-06-26T09-01

Policy Order:
1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.claude/rules/general-code-change.md` — baseline cross-language code change rules
3. `.claude/rules/general-unit-test.md` — baseline cross-language unit test rules
4. Language- and domain-specific rules in scope:
   - TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
   - Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
   - Architecture: `.claude/rules/architecture-boundaries.md`
   - Tiers: `.claude/rules/quality-tiers.md`
   - Commenting: `.claude/rules/self-explanatory-code-commenting.md`
   - Tonality: `.claude/rules/tonality.md`

Files Read:
- `.github/copilot-instructions.md` (via CLAUDE.md standing instructions) — tone policy, policy-compliance reading order, four-layer architecture.
- `.claude/rules/general-code-change.md` — design principles, 500-line file limit, mandatory toolchain loop, error handling, I/O boundaries.
- `.claude/rules/general-unit-test.md` — five core test properties, coverage (line >= 85%, branch >= 75%), no temp files, test-file mirror location, AAA structure.
- `.claude/rules/typescript.md` — toolchain order, strong typing, no `any`, ES modules, kebab-case filenames, coverage thresholds.
- `.claude/rules/typescript-suppressions.md` — pre-authorized single-line suppressions only; prohibited file-level disables and `@ts-ignore`/`@ts-nocheck`.
- `.claude/rules/python.md` — Black/Ruff/Pyright/Pytest toolchain; coverage thresholds; coding standards.
- `.claude/rules/python-suppressions.md` — Python suppression authorization policy.
- `.claude/rules/architecture-boundaries.md` — layer boundary and No-COM assertions; dependency-cruiser is the TS enforcement tool.
- `.claude/rules/quality-tiers.md` — T1–T4 tiers; uniform coverage thresholds.
- `.claude/rules/self-explanatory-code-commenting.md` — intent-first docstrings/comments standard.
- `.claude/rules/tonality.md` — professional tone; no humor, hyperbole, decorative metaphor; evidence-first wording.

Notes:
- Toolchain deviation recorded: the `extensions/drm-copilot` package uses Jest (not Vitest, which `.claude/rules/typescript.md` names). Per the explicit F11 feature directive and the plan (spec decision D1), Jest is the test framework for this package. TS commands: `npm run format`, `npm run lint`, `npm run typecheck`, `node run-jest.cjs`.
- Both suites must remain green: the TypeScript suite under `extensions/drm-copilot/` and the repository Python suite via `poetry run pytest`.
- All new filesystem I/O routes through the injected F1 `FileSystem` (`src/lib/file-system.ts`); tests are hermetic with an in-memory fake.
