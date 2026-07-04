# Phase 0 — Policy Instructions Read Evidence

Timestamp: 2026-06-13T11-51

Policy Order:
1. CLAUDE.md (standing instructions, always loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. Language- and domain-specific rules in scope (Python + Markdown):
   - .claude/rules/python.md
   - .claude/rules/python-suppressions.md
   - .claude/rules/quality-tiers.md
   - .claude/rules/self-explanatory-code-commenting.md
   - .claude/rules/tonality.md

Files Read (explicit list):
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/quality-tiers.md
- .claude/rules/self-explanatory-code-commenting.md
- .claude/rules/tonality.md

Output Summary: All eight policy files read in required order. Confirmed root coverage policy is 85% line / 75% branch with the T1-T4 tier system; the 500-line file cap applies to production and test files (Markdown documentation exempt); the Python toolchain order is Black -> Ruff -> Pyright -> Pytest, restarting from formatting on any failure or file change. Docstring/commenting policy requires full docstrings on all classes and functions including private helpers.
