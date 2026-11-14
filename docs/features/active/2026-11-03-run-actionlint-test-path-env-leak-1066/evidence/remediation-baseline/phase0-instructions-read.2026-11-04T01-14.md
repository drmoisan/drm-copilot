# Phase 0 Instructions Read — Remediation Cycle 1 (Issue #1066)

Timestamp: 2026-11-04T01-14
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> skills (execution-environment, atomic-plan-contract, evidence-and-timestamp-conventions, acceptance-criteria-tracking) -> remediation inputs, approved plan, spec

Files read, in order:

1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/powershell.md
5. .claude/skills/execution-environment/SKILL.md
6. .claude/skills/atomic-plan-contract/SKILL.md
7. .claude/skills/evidence-and-timestamp-conventions/SKILL.md
8. .claude/skills/acceptance-criteria-tracking/SKILL.md
9. docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/remediation-inputs.2026-11-04T01-03.md
10. docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/plan.2026-11-03T17-43.md (APPROVED)
11. docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/spec.md

Constraints noted: edit only TARGET, GUARD, and the feature folder; no production file; no new Python; tests create no temporary files; PoshQC MCP results carry no output, so counts come from JUnit and coverage files written by SCRATCH tooling.
