# r3c3 Phase 0 — Policy Instructions Read

Timestamp: 2026-07-18T23-30

Policy Order:
1. CLAUDE.md (standing instructions, always loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. Language- or domain-specific rules based on files in scope:
   - PowerShell: .claude/rules/powershell.md
   - Python: .claude/rules/python.md, .claude/rules/python-suppressions.md
   - .claude/rules/tonality.md

Files Read:
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/tonality.md
- .claude/rules/quality-tiers.md (loaded via CLAUDE.md context; referenced for uniform coverage thresholds)

Notes:
- Remediation cycle 3 for issue #369, PR #384, branch feature/legacy-discovery-dotnet-vsto-analyzers-369.
- Scope: produce the mandatory PowerShell coverage artifact for the two discovery-artifact-gate hooks (acceptance option 1 only).
- Editing any policy document under .claude/rules/ or .github/instructions/ is forbidden (CLAUDE.md, policy-compliance-order hard constraints). No policy rule file is modified in this cycle.
- PowerShell coverage thresholds required: line >= 85%, branch >= 75% (.claude/rules/powershell.md, .claude/rules/quality-tiers.md).
- Python toolchain order: Black -> Ruff -> Pyright -> Pytest (--cov --cov-branch), must remain green with no regression.
