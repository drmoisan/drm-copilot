# Phase 0 Instructions Read - Issue #1096

Timestamp: 2026-11-07T14-05
Plan: docs/features/active/2026-11-06-pester-static-leak-scan-1096/plan.2026-11-07T02-06.md
Task: P0-T1
Command: git branch --show-current (through -C to the item worktree)
EXIT_CODE: 0
Output Summary: branch is feature/pester-static-leak-scan-1096; policy files read in the policy-compliance-order sequence.

Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language and domain rules -> feature spec

## Files Read

1. `CLAUDE.md`
2. `.claude/rules/tonality.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/quality-tiers.md` (no `quality-tiers.yml` at the repository root, so tier gates do not apply)
6. `.claude/rules/powershell.md`
7. `.claude/rules/python.md`
8. `.claude/rules/python-suppressions.md`
9. `.claude/rules/ci-workflows.md`
10. `.claude/rules/plan-acceptance-gates.md`
11. `.claude/skills/execution-environment/SKILL.md`
12. `.claude/skills/atomic-plan-contract/SKILL.md`
13. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
14. `.claude/skills/acceptance-criteria-tracking/SKILL.md`
15. `docs/features/active/2026-11-06-pester-static-leak-scan-1096/spec.md`

## Notes

- Work Mode is `full-feature`; acceptance criteria are tracked in `spec.md` and `user-story.md`.
- Coverage thresholds: 85% line for PowerShell (no branch gate); 85% line and 75% branch for Python.
