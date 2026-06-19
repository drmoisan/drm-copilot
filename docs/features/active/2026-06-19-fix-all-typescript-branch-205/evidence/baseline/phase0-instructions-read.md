# Phase 0 — Instructions Read (Issue #205)

Timestamp: 2026-06-19T18-05

Policy Order:
1. `.claude/rules/general-code-change.md`
2. `.claude/rules/general-unit-test.md`
3. `.claude/rules/python.md`
4. `.claude/rules/python-suppressions.md`
5. `.github/instructions/python-code-change.instructions.md`
6. `.github/instructions/python-unit-test.instructions.md`

Files read (in required order):
- `.claude/rules/general-code-change.md` — cross-language code change policy; mandatory toolchain loop (format -> lint -> type-check -> test); 500-line file limit.
- `.claude/rules/general-unit-test.md` — core unit test principles; coverage requirements (line >= 85%, branch >= 75%); scenario completeness; AAA structure; no temp files/external services.
- `.claude/rules/python.md` — Python toolchain (Black, Ruff, Pyright, Pytest); typing and design rules; patch at import location used by the unit under test.
- `.claude/rules/python-suppressions.md` — suppression authorization policy; no unauthorized `# noqa` / `# type: ignore`.
- `.github/instructions/python-code-change.instructions.md` — Python code change rules layered on general policy.
- `.github/instructions/python-unit-test.instructions.md` — Python unit test rules layered on general policy.

Supplemental rule read for this task (referenced by P1-T1 commenting requirements):
- `.claude/rules/self-explanatory-code-commenting.md` — mandatory docstrings; intent comments for loops and branching.

Key constraints confirmed:
- All production/test/script files must be < 500 lines.
- Line coverage >= 85%, branch coverage >= 75% across all tiers.
- No unauthorized `# noqa` / `# type: ignore` suppressions.
- Mandatory toolchain order: format -> lint -> type-check -> test; restart on any change.
- No temp files or external processes in unit tests.
