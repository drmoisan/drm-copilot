Timestamp: 2026-07-18T16-19
Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`

Files read, in order:
1. `CLAUDE.md` — repository-wide tone policy, policy compliance reading order, and four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles, mandatory seven-stage toolchain loop, file size limit, error handling, naming, API compatibility, dependencies, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: core test principles, uniform coverage requirements (line >= 85%, branch >= 75%), coverage exclusion policy, scenario completeness, AAA structure, external-dependency rules, test file location, determinism infrastructure.
4. `.claude/rules/python.md` — Python-specific toolchain (Black, Ruff, Pyright, Pytest) and coding standards, Pytest rules, and prohibited behaviors.
