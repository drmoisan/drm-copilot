# Phase 0 Policy Reads (Issue #1074)

Timestamp: 2026-11-04T15-26
Task: [P0-T1]
Policy Order: CLAUDE.md, then the general code-change and unit-test policies, then the language and domain policies in scope (PowerShell, Python test, GitHub Actions workflows), then the execution-environment and atomic-plan-contract skills.

Files read, in order:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.github/instructions/python-unit-test.instructions.md`
8. `.github/instructions/github-actions.instructions.md`
9. `.claude/rules/powershell.md`
10. `.claude/rules/python.md`
11. `.claude/rules/ci-workflows.md`
12. `.claude/skills/execution-environment/SKILL.md`
13. `.claude/skills/atomic-plan-contract/SKILL.md`

Key constraints recorded:

- No new Python file; new code is PowerShell (`scripts/ci/CiRequiredGate.psm1`, `scripts/ci/Invoke-CiRequiredGate.ps1`).
- Tests create no temporary files and do not read or write `NEEDS_JSON` or `GITHUB_STEP_SUMMARY` directly.
- A `pwsh` workflow step that ends on a verdict ends with an explicit `exit 0` or `exit 1` (`.claude/rules/ci-workflows.md`).
- Workflows must pass actionlint (`scripts/dev-tools/run-actionlint.ps1`).
- PowerShell line coverage floor 85% per new production file; counts and coverage are read from `artifacts/pester/` files, not from MCP result summaries.
- Ruleset 15241672 is read with a GET only; no PUT, PATCH, or POST is sent.
