# Phase 0 — Instructions Read

Timestamp: 2026-06-19T17-36

Policy Order:
1. `.github/instructions/general-code-change.instructions.md`
2. `.github/instructions/python-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/python-unit-test.instructions.md`

Files read (in required order):
- `.github/instructions/general-code-change.instructions.md` — baseline cross-language code change policy, mandatory toolchain loop (format -> lint -> type-check -> test), 500-line file limit.
- `.github/instructions/python-code-change.instructions.md` — Python toolchain (Black, Ruff, Pyright), typing and design rules.
- `.github/instructions/general-unit-test.instructions.md` — core unit test principles, coverage and scenario completeness, AAA structure.
- `.github/instructions/python-unit-test.instructions.md` — Pytest framework requirement, coverage command, test style.

Additional standing policy context loaded via `CLAUDE.md` and `.claude/rules/` (python.md, python-suppressions.md, quality-tiers.md, general-code-change.md, general-unit-test.md).
