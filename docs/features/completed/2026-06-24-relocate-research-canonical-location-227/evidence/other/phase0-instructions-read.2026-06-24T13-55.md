# Phase 0 — Policy Instructions Read (Issue #227 remediation)

Timestamp: 2026-06-24T13-55

Policy Order:
1. CLAUDE.md (standing instructions; always loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/quality-tiers.md (T1–T4 tier system; uniform coverage thresholds)
5. .claude/rules/powershell.md (PowerShell toolchain and coding standards)

Files Read:
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/quality-tiers.md
- .claude/rules/powershell.md

Output Summary: All five policy files read in the required order. Key constraints
confirmed for this remediation: line coverage >= 85% and branch coverage >= 75%
uniform across tiers; no coverage exclusions permitted (refactor untestable lines
into testable functions rather than excluding); no assertion weakening; PowerShell
toolchain order is format -> analyze -> test (type-check N/A); per-batch cap 3
production + 3 test files; all files must remain under 500 lines.
