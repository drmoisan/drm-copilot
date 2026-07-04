# Phase 0 Policy-Read Evidence

Timestamp: 2026-06-16T15-30

Policy Order:
1. CLAUDE.md (standing instructions; tone, policy-compliance order, architecture)
2. .claude/rules/general-code-change.md (cross-language code change policy; 500-line file limit)
3. .claude/rules/general-unit-test.md (cross-language unit test policy; coverage thresholds)
4. Language-specific rules for files in scope:
   - Python: .claude/rules/python.md, .claude/rules/python-suppressions.md
   - Commenting: .claude/rules/self-explanatory-code-commenting.md
   - PowerShell: .claude/rules/powershell.md
   - Domain: .claude/rules/orchestrator-state.md, .claude/rules/quality-tiers.md

Files read:
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/self-explanatory-code-commenting.md
- .claude/rules/powershell.md
- .claude/rules/orchestrator-state.md
- .claude/rules/quality-tiers.md

Output Summary: All nine listed policy files were read prior to any code or test
change. Key constraints applied to this remediation: 500-line file limit
(general-code-change.md), uniform coverage thresholds line >= 85% / branch >= 75%
(quality-tiers.md, general-unit-test.md), mandatory docstrings for moved module
and function (self-explanatory-code-commenting.md), foreign-schema prohibition
(orchestrator-state.md), and the Python toolchain order Black -> Ruff -> Pyright
-> Pytest (python.md).
