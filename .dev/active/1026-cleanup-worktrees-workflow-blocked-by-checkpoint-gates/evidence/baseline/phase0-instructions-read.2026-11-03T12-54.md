# Phase 0 Instructions Read (Issue #1026)

Timestamp: 2026-11-03T12-54
Plan: docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/plan.2026-11-03T06-52.md
Task: [P0-T1]

Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> .claude/rules/python.md (Python in scope only to run existing contract tests) -> skills execution-environment, atomic-plan-contract, evidence-and-timestamp-conventions, acceptance-criteria-tracking

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md`
6. `.claude/skills/execution-environment/SKILL.md`
7. `.claude/skills/atomic-plan-contract/SKILL.md`
8. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
9. `.claude/skills/acceptance-criteria-tracking/SKILL.md`

Constraints recorded for execution:

- No new Python file; no hook invokes Python; all new hook and library logic is PowerShell.
- Toolchain loop for PowerShell: Invoke-Formatter, PSScriptAnalyzer with the PoshQC settings, Pester; restart on any change or failure.
- Line coverage of at least 85% per new PowerShell production file; no PowerShell branch gate.
- Tests create no temporary files; every external seam is mocked; fixtures are POSIX-rooted.
- Evidence under `<FEATURE>/evidence/<kind>/` with write-time UTC stamps; scratch recorded only as the token `SCRATCH`.
