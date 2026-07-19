# r2c2 Phase 0 — Policy Instructions Read

Timestamp: 2026-07-18T22-58

Policy Order:
1. CLAUDE.md (standing instructions)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/python.md (Python toolchain and coding standards)
5. .claude/rules/python-suppressions.md (Python suppression authorization policy)
6. .claude/rules/tonality.md (tone policy)

Files Read:
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/tonality.md

Notes:
- CLAUDE.md, general-code-change.md, general-unit-test.md, and tonality.md were loaded via the standing-instructions context at session start.
- python.md and python-suppressions.md were read explicitly for this cycle because the QA loop for this remediation is the Python toolchain (Black, Ruff, Pyright, Pytest).
- Scope confirmed: the change copies two byte-identical PowerShell resource files into the bundled extension payload with no PowerShell authored-logic change, so only the Python toolchain applies as the QA loop.
