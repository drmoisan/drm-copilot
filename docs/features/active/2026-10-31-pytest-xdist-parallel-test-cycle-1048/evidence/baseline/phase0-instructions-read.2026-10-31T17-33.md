# Phase 0 Instructions Read (#1048)

Timestamp: 2026-10-31T17-33
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language-specific (Python, PowerShell) -> CI workflows -> execution-environment brief

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`
7. `.claude/rules/ci-workflows.md`
8. `.claude/skills/execution-environment/SKILL.md` (execution-environment brief)

Additional context read: `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, and in this folder `spec.md` and `owner-decisions.md`.

Key constraints recorded: no new Python script; `-n` never in `addopts`; fix leaker and victim for any order dependence; Pester runner in PowerShell; files at or below 800 lines; line coverage at least 85% (PowerShell has no branch gate); evidence under `FEATURE/evidence/<kind>/`.
