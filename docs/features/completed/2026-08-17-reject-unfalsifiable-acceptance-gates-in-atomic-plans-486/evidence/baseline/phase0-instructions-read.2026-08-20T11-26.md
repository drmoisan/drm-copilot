# Phase 0 Policy Read Record

Timestamp: 2026-08-20T11-26
Task: [P0-T1]
Issue: #486

Policy Order: the reading order defined by `.claude/skills/policy-compliance-order/SKILL.md`, applied to the nine files enumerated by plan task [P0-T1] in the order given there.

Files read, in order:

1. `CLAUDE.md` — standing instructions: tone policy, policy-compliance reading order, path-scoped rule loading, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — design principles, class-vs-function guidance, mandatory seven-stage toolchain loop, 500-line file ceiling, error handling, naming, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — five core unit-test properties, uniform coverage thresholds (>= 85% line, >= 75% branch), coverage exclusion policy, scenario completeness, Arrange-Act-Assert, prohibition on temporary files, test-file location under `tests/` mirroring source.
4. `.claude/rules/python.md` — Black, Ruff, Pyright, Pytest toolchain and order; PEP 8 naming; strong typing; dataclasses; Protocols; dependency seams; pytest rules; prohibited behaviors.
5. `.claude/rules/python-suppressions.md` — authorization requirement for `# noqa` and `# type: ignore`; pre-authorized patterns; explicitly unauthorized patterns and required workarounds.
6. `.claude/rules/typescript.md` — Prettier, ESLint, TSC, Jest toolchain and order; ES modules; kebab-case filenames; testing standards; coverage thresholds; determinism requirements.
7. `.claude/rules/typescript-suppressions.md` — authorization requirement for ESLint and TypeScript suppressions; pre-authorized single-line forms; prohibited file-level and `@ts-ignore` forms.
8. `.claude/rules/quality-tiers.md` — T1-T4 tier definitions, `quality-tiers.yml` as source of truth, uniform-versus-tier-dependent gate matrix.
9. `.claude/rules/tonality.md` — professional tone requirement; prohibition on humor, hyperbole, and decorative metaphor; evidence-first wording.

Output Summary: All nine policy files were read in the order above prior to any code or test change in this batch. No policy file was modified.
