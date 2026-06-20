# Phase 0 — Instructions Read (Issue #214)

Timestamp: 2026-06-19T21-18

Policy Order:
1. CLAUDE.md (standing instructions, tone + policy-compliance order)
2. .claude/rules/general-code-change.md (cross-language code-change policy)
3. .claude/rules/general-unit-test.md (cross-language unit-test policy)
4. .claude/rules/powershell.md (PowerShell toolchain + coding standards; seam pattern; mocking rules)
5. .claude/rules/quality-tiers.md (T1-T4 rigor tiers; uniform coverage thresholds)
6. .claude/rules/ci-workflows.md (GitHub Actions pwsh exit-code rule)
7. .claude/rules/benchmark-baselines.md (benchmark baseline provenance; not in scope but read)
8. .claude/skills/evidence-and-timestamp-conventions/SKILL.md (canonical evidence paths + artifact schema)

Files Read (explicit list):
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md
- .claude/rules/quality-tiers.md
- .claude/rules/ci-workflows.md
- .claude/rules/benchmark-baselines.md
- .claude/skills/evidence-and-timestamp-conventions/SKILL.md

Output Summary: All eight policy files were read in the required order. Key constraints captured: external executable calls isolated behind wrapper-function seams (Invoke-GitExe/Invoke-NpmExe/Invoke-GhExe); tests mock seams with matching named-parameter signatures, never git/gh/npm directly; no production/test/script file may exceed 500 lines; line coverage >= 85% and branch coverage >= 75% uniform across tiers; PoshQC toolchain order is format -> analyze -> test with restart-on-change; CI pwsh steps with deliberately-failing nested commands must reset exit code; all evidence artifacts resolve to docs/features/active/separate-version-bump-from-publish-214/evidence/<kind>/.
