# Phase 0 — Policy Instructions Read

Timestamp: 2026-06-24T13-09

Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> language-specific (PowerShell, Python) -> supporting rules

Files read (in order):
- CLAUDE.md (standing instructions, auto-loaded)
- .claude/rules/general-code-change.md (cross-language code change policy)
- .claude/rules/general-unit-test.md (cross-language unit test policy)
- .claude/rules/powershell.md (PowerShell toolchain and coding standards)
- .claude/rules/python.md (Python toolchain and coding standards)
- .claude/rules/python-suppressions.md (Python suppression authorization policy)
- .claude/rules/self-explanatory-code-commenting.md (commenting and docstring policy)
- .claude/rules/quality-tiers.md (T1-T4 rigor tier system; uniform coverage thresholds)

Notes:
- Languages in scope for this feature: PowerShell (hooks + tests) and Python (validator + tests). Remaining edits are prose/instruction/allowlist text in Markdown and TOML.
- Coverage thresholds (uniform across tiers): line >= 85%, branch >= 75%; no regression on changed lines.
- Mandatory toolchain order — PowerShell: PoshQC format -> analyze -> Pester; Python: Black -> Ruff -> Pyright -> Pytest.
